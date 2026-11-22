local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@lpm/batteries@v1.0.1-nightly.20261115/richterm")

local chomp = require("@root/chomp")
local config = require("@root/config")
local convertMarkdownEntry = require("@root/entries/convertMarkdownEntry")
local detectAddedEntries = require("@root/release/detectAddedEntries")
local findMarkdownEntries = require("@root/release/findMarkdownEntries")
local findStaleChipAssets = require("@root/chips/findStaleChipAssets")
local findSummaryProblems = require("@root/entries/findSummaryProblems")
local getAssetsDir = require("@root/chips/getAssetsDir")
local getCurrentBranch = require("@root/release/getCurrentBranch")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local isPublishBranch = require("@root/release/isPublishBranch")
local isSameRepositoryPullRequest = require("@root/release/isSameRepositoryPullRequest")
local readCategories = require("@root/release/readCategories")
local readChipStyles = require("@root/chips/readChipStyles")
local readCollapsedCategories = require("@root/release/readCollapsedCategories")
local readGithubEvent = require("@root/release/readGithubEvent")
local readKindNames = require("@root/release/readKindNames")
local readMaxSummaryLength = require("@root/release/readMaxSummaryLength")
local readPublishBranch = require("@root/release/readPublishBranch")
local readReleaseSummary = require("@root/release/readReleaseSummary")
local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local releaseTypes = require("@root/release/types")
local resolveBaseBranch = require("@root/release/resolveBaseBranch")
local splitLines = require("@root/release/splitLines")
local types = require("@root/cli/types")

local title = "check"
local summary = "Validate the unreleased changelog entries for the current branch."

local parser = cli.parser()
parser:add("base", "option", {
	help = "Base ref to diff against when detecting a newly added entry. Defaults to the pull request's base branch on GitHub Actions, otherwise the repository's default branch.",
})
parser:add("publish-branch", "option", {
	help = "Pass on this publish branch instead of `release.branch` from changewrite.toml.",
})
parser:add("fix", "flag", {
	help = "Convert Markdown entries to Luau before checking.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function formatChangelogTemplate(categories: { string }?, kinds: { string }): string
	local category = if categories == nil or table.find(categories, "Fixes") then "Fixes" else categories[1]
	local lines = {
		"return {",
		'\tbump = "patch",',
		`\tcategory = "{category}",`,
	}
	if #kinds > 0 then
		table.insert(lines, `\tkind = "{kinds[1]}",`)
	end
	table.insert(lines, '\tsummary = "One short sentence describing the change, written for the changelog.",')
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

local function printNoChangesError()
	local dir = getUnreleasedChangesDir()
	local categories = readCategories()
	local kinds = readKindNames()

	print(richterm.red("A changelog entry is required."))
	print("")
	print(`Add a Luau entry under {richterm.bold(tostring(dir))} describing this change:`)
	print("")
	print(richterm.bold("Template:"))
	print(formatChangelogTemplate(categories, kinds))
	print("")
	print(richterm.bold("Guide:"))
	print("  • bump (required): major, minor, or patch")
	if categories then
		print(`  • category (required): one of {table.concat(categories, ", ")}`)
	else
		print("  • category (optional): the heading to list it under, Changes by default")
	end
	if #kinds > 0 then
		print(`  • kind (required): one of {table.concat(kinds, ", ")}`)
	end
	print("  • flags (optional): a list of any of breaking, deprecated, security")
	print("  • highlight (optional): a short title for a headline change")
	print(`  • summary (required): one short sentence, at most {readMaxSummaryLength()} characters`)
	print("  • body (optional): more detail, rendered after the summary")
	print("  • filename: name after the change (e.g., fix-release-permissions.luau)")
	print("")
	print(`See {path.join(dir, "README.md")} for details.`)
end

local function printNoBaseRefError()
	print(richterm.red("Could not determine a base ref to compare against."))
	print("")
	print(richterm.bold("To fix:"))
	print("  • Pass the base branch with --base <ref>.")
	print("  • Or set the remote's default branch (git remote set-head origin --auto).")
end

-- The diff needs both the base ref and a common ancestor with HEAD. On CI this
-- usually fails because the checkout is shallow, so point at the concrete fix
-- rather than surfacing git's raw error.
local function printBaseRefError(baseRef: string, stderr: string)
	print(richterm.red(`Could not compare against base ref "{baseRef}".`))
	print("")
	print("This usually means the base ref is missing or the checkout has too little history.")
	print("")
	print(richterm.bold("To fix:"))
	print("  • Check out with full history (actions/checkout: fetch-depth: 0).")
	print(`  • Ensure "{baseRef}" is fetched, or pass a different ref with --base <ref>.`)

	local trimmed = chomp(stderr)
	if trimmed ~= "" then
		print("")
		print(richterm.bold("git said:"))
		print(trimmed)
	end
end

-- Entry files that exist only in the working tree, so a local run can confirm a
-- just-created entry before it is committed. On CI the checkout is clean, so
-- these listings come back empty and the committed diff alone decides the run.
local function collectWorkingTreeAdditions(dir: path.Path): { string }
	local paths: { string } = {}

	-- New files staged against HEAD but not yet committed. A brand-new file only
	-- shows here once it is tracked; while still untracked it is caught below.
	local tracked = process.run({
		config.gitCmd,
		"diff",
		"--name-only",
		"--diff-filter=A",
		"HEAD",
		"--",
		tostring(dir),
	})
	if tracked.ok then
		for _, line in splitLines(tracked.stdout) do
			table.insert(paths, line)
		end
	end

	-- New files that have not been staged yet, minus anything gitignored.
	local untracked = process.run({
		config.gitCmd,
		"ls-files",
		"--others",
		"--exclude-standard",
		"--",
		tostring(dir),
	})
	if untracked.ok then
		for _, line in splitLines(untracked.stdout) do
			table.insert(paths, line)
		end
	end

	return paths
end

-- GitHub Actions sets GITHUB_HEAD_REF only for pull_request and
-- pull_request_target runs.
local function isPullRequestRun(): boolean
	local headRef = process.env.GITHUB_HEAD_REF
	return headRef ~= nil and headRef ~= ""
end

-- Chips only matter to a repo that uses them: one that configures kinds, has
-- entries with a kind or flags, or has generated chips before.
local function usesChips(entries: { releaseTypes.UnreleasedChange }): boolean
	if #readKindNames() > 0 or fs.exists(getAssetsDir()) then
		return true
	end
	for _, entry in entries do
		if entry.kind ~= nil or #entry.flags > 0 then
			return true
		end
	end
	return false
end

local function checkChips(entries: { releaseTypes.UnreleasedChange })
	-- Reading the styles validates every [kind] and [flag] table, which matters
	-- even in a repo that hasn't used a chip yet.
	readChipStyles()
	if not usesChips(entries) then
		return
	end
	local stale = findStaleChipAssets()
	if #stale > 0 then
		print(richterm.red("Chips don't match changewrite.toml. Run `changewrite generate` and commit the result:"))
		for _, line in stale do
			print(`  • {line}`)
		end
		process.exit(1)
	end
end

local function fixEntries()
	for _, file in findMarkdownEntries() do
		local target = path.parse(path.format(file):gsub("%.[mM][dD]$", ".luau"))
		assert(not fs.exists(target), `Can't convert {file}: {target} already exists`)
		local success, converted = pcall(convertMarkdownEntry, fs.readFileToString(file))
		assert(success, `{file}: {converted}`)
		fs.writeStringToFile(target, converted)
		fs.remove(file)
		print(`Converted {file} to {target}.`)
	end
end

local function checkMarkdownEntries()
	local files = findMarkdownEntries()
	if #files == 0 then
		return
	end
	print(richterm.red("Changelog entries are written in Luau. Run `changewrite check --fix` to convert these:"))
	for _, file in files do
		print(`  • {file}`)
	end
	process.exit(1)
end

local function checkSummaries(entries: { releaseTypes.UnreleasedChange })
	local maxLength = readMaxSummaryLength()
	local count = 0
	for _, entry in entries do
		for _, problem in findSummaryProblems(entry.summary, maxLength) do
			print(`{entry.file}: {problem}`)
			count += 1
		end
	end
	if count > 0 then
		print(richterm.red(`Found {count} problem{if count == 1 then "" else "s"} in changelog entries.`))
		process.exit(1)
	end
end

local function run()
	if parser:has("fix") then
		fixEntries()
	end
	checkMarkdownEntries()
	local entries = readUnreleasedChanges()
	readReleaseSummary()
	readCollapsedCategories()
	checkSummaries(entries)
	checkChips(entries)

	local currentBranch = getCurrentBranch()
	local publishBranch = parser:get("publish-branch")
	if not publishBranch or publishBranch == "" then
		publishBranch = readPublishBranch()
	end
	assert(publishBranch)

	-- In a pull request the current branch is the PR's head, which a fork names
	-- freely. Only a head branch in this repository can be the publish branch,
	-- and a pull request never runs on the base branch itself.
	local inPullRequest = isPullRequestRun()
	local fromThisRepository = not inPullRequest or isSameRepositoryPullRequest(readGithubEvent())

	if currentBranch and fromThisRepository and isPublishBranch(currentBranch, publishBranch) then
		print(`Skipping the entry check on the publish branch ({currentBranch}).`)
		return
	end

	local baseRef = parser:get("base")
	if not baseRef then
		local baseBranch = resolveBaseBranch()
		if not baseBranch then
			printNoBaseRefError()
			process.exit(1)
		end
		assert(baseBranch)

		if not inPullRequest and currentBranch == baseBranch then
			print(`Skipping the entry check on the base branch ({baseBranch}).`)
			return
		end
		baseRef = `origin/{baseBranch}`
	end
	assert(baseRef)

	local dir = getUnreleasedChangesDir()

	-- Added files between the merge-base of the base ref and HEAD, limited to
	-- the unreleased-changes directory. The three-dot range reports what this
	-- branch added, not what differs from the current base tip.
	local diff = process.run({
		config.gitCmd,
		"diff",
		"--name-only",
		"--diff-filter=A",
		`{baseRef}...HEAD`,
		"--",
		tostring(dir),
	})

	if not diff.ok then
		printBaseRefError(baseRef, diff.stderr)
		process.exit(1)
	end

	-- Count entries added on the branch and entries that only exist in the
	-- working tree, so `check` passes locally before the entry is committed.
	local candidates = splitLines(diff.stdout)
	for _, line in collectWorkingTreeAdditions(dir) do
		table.insert(candidates, line)
	end

	local addedEntries = detectAddedEntries(candidates, dir)
	if #addedEntries == 0 then
		printNoChangesError()
		process.exit(1)
	end

	local noun = if #addedEntries == 1 then "entry" else "entries"
	print(`Found {#addedEntries} new unreleased change {noun} on this branch.`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
