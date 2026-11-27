local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local path = require("@std/path")
local process = require("@std/process")

local PreviewCommentStep = require("@root/release/PreviewCommentStep")
local config = require("@root/config")
local constants = require("@root/release/constants")
local findBranchEntries = require("@root/release/findBranchEntries")
local getPullRequestNumber = require("@root/release/getPullRequestNumber")
local isSameRepositoryPullRequest = require("@root/release/isSameRepositoryPullRequest")
local planPreviewComment = require("@root/release/planPreviewComment")
local readCollapsedCategories = require("@root/release/readCollapsedCategories")
local readGithubEvent = require("@root/release/readGithubEvent")
local readReleaseSummary = require("@root/release/readReleaseSummary")
local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local releaseTypes = require("@root/release/types")
local renderPreviewComment = require("@root/release/renderPreviewComment")
local renderReleaseSection = require("@root/release/renderReleaseSection")
local resolveBaseBranch = require("@root/release/resolveBaseBranch")
local resolveReleaseVersion = require("@root/release/resolveReleaseVersion")
local splitLines = require("@root/release/splitLines")
local types = require("@root/cli/types")
local usesRichNotes = require("@root/release/notes/usesRichNotes")

type UnreleasedChange = releaseTypes.UnreleasedChange

local title = "preview"
local summary = "Preview how the current branch's changelog entries will read in the next release."

local parser = cli.parser()
parser:add("base", "option", {
	help = "Base ref to diff against when finding the branch's entries. Defaults to the pull request's base branch on GitHub Actions, otherwise the repository's default branch.",
})
parser:add("comment", "flag", {
	help = "Post the preview as a comment on the pull request this GitHub Actions run is for, update the one already there, or delete it once the pull request adds no entries.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function resolveBaseRef(): string
	local baseRef = parser:get("base")
	if baseRef then
		return baseRef
	end
	local baseBranch = resolveBaseBranch()
	assert(
		baseBranch,
		"Could not determine a base ref to compare against. Pass --base <ref>, or set the remote's default branch (git remote set-head origin --auto)."
	)
	return `origin/{baseBranch}`
end

local function normalize(file: path.Pathlike): string
	return tostring(path.normalize(path.parse(file)))
end

-- The preview of the branch's entries, or nil when it adds none.
local function renderPreview(pullRequest: number?): string?
	local changes = readUnreleasedChanges()

	local baseRef = resolveBaseRef()
	local branchEntries = findBranchEntries(baseRef)
	assert(branchEntries.err == nil, `Could not compare against base ref "{baseRef}": {branchEntries.err}`)

	local isAdded: { [string]: true } = {}
	for _, file in branchEntries.entries do
		isAdded[normalize(file)] = true
	end
	local focus: releaseTypes.Focus = {}
	local others: { UnreleasedChange } = {}
	local hasFocus = false
	for _, change in changes do
		if isAdded[normalize(change.file)] then
			focus[tostring(change.file)] = true
			hasFocus = true
		else
			table.insert(others, change)
		end
	end
	if not hasFocus then
		return nil
	end

	local version = resolveReleaseVersion(changes)
	local releaseSummary = readReleaseSummary()
	local collapsed = readCollapsedCategories()
	return renderPreviewComment({
		section = renderReleaseSection(version, changes, {
			focus = focus,
			pullRequest = pullRequest,
		}),
		version = version,
		versionWithout = if #others > 0 then resolveReleaseVersion(others) else nil,
		switchesToRichNotes = #others > 0
			and usesRichNotes(changes, releaseSummary, collapsed)
			and not usesRichNotes(others, releaseSummary, collapsed),
	})
end

local function runGh(args: { string }): string
	local command = { config.ghCmd }
	table.move(args, 1, #args, 2, command)
	local result = process.run(command)
	assert(result.ok, `gh {args[1]} {args[2] or ""} failed: {result.stderr}`)
	return result.stdout
end

-- Makes the pull request's preview comment match `body`.
local function syncComment(repo: string, pullRequest: number, body: string?)
	local listed = runGh({
		"api",
		"--paginate",
		`repos/{repo}/issues/{pullRequest}/comments`,
		"--jq",
		`.[] | select(.body | startswith("{constants.PREVIEW_COMMENT_MARKER}")) | .id`,
	})
	local existingIds: { number } = {}
	for _, line in splitLines(listed) do
		-- With no preview comment yet, gh prints nothing, which splits into one
		-- empty line.
		if line ~= "" then
			table.insert(existingIds, assert(tonumber(line), `gh listed a comment id that isn't a number: {line}`))
		end
	end

	for _, planned in planPreviewComment(existingIds, body) do
		if planned.step == PreviewCommentStep.Create and body then
			runGh({
				"api",
				`repos/{repo}/issues/{pullRequest}/comments`,
				"-f",
				`body={body}`,
			})
			print(`Posted the changelog preview on #{pullRequest}.`)
		elseif planned.step == PreviewCommentStep.Update and body then
			runGh({
				"api",
				"-X",
				"PATCH",
				`repos/{repo}/issues/comments/{planned.commentId}`,
				"-f",
				`body={body}`,
			})
			print(`Updated the changelog preview on #{pullRequest}.`)
		elseif planned.step == PreviewCommentStep.Delete then
			runGh({
				"api",
				"-X",
				"DELETE",
				`repos/{repo}/issues/comments/{planned.commentId}`,
			})
			print(`Deleted a changelog preview from #{pullRequest}.`)
		end
	end
end

local function run()
	if not parser:has("comment") then
		print(renderPreview(nil) or "This branch adds no changelog entries, so there is nothing to preview.")
		return
	end

	local event = readGithubEvent()
	local pullRequest = getPullRequestNumber(event)
	assert(pullRequest, "--comment needs a GitHub Actions run for a pull request.")
	--[[
		A pull request from a fork runs with a read-only token, which can't
		post a comment. Its author can run `changewrite preview` locally
		instead.
	]]
	if not isSameRepositoryPullRequest(event) then
		print("Skipping the changelog preview comment on a pull request from a fork.")
		return
	end

	local repo = process.env.GITHUB_REPOSITORY
	assert(repo and repo ~= "", "--comment needs GITHUB_REPOSITORY, which GitHub Actions sets.")
	local preview = renderPreview(pullRequest)
	syncComment(repo, pullRequest, if preview then `{constants.PREVIEW_COMMENT_MARKER}\n{preview}` else nil)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
