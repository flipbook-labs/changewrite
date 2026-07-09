local cli = require("@batteries/cli")
local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")
local publishLockStatus = require("@root/release/publishLockStatus")
local types = require("@root/cli/types")

-- `lock` and `unlock` are the same operation with opposite states: both post the
-- `publish-lock` commit status to a commit, differing only in success/failure.
-- This factory builds either command so the shared plumbing (locating the
-- commit, calling gh) lives in one place.
local function createPublishLockCommand(options: {
	title: string,
	summary: string,
	state: publishLockStatus.State,
}): types.Command
	local parser = cli.parser()
	parser:add("branch", "option", {
		help = `Post the status to this branch's head commit. Defaults to the publish branch ({publishLockStatus.DEFAULT_PUBLISH_BRANCH}).`,
	})
	parser:add("sha", "option", {
		help = "Post the status to this exact commit instead of a branch head. Takes precedence over --branch.",
	})
	parser:add("repo", "option", {
		help = "Repository as owner/name. Defaults to the repository gh infers.",
	})
	parser:add("url", "option", {
		help = 'URL the status badge links to in the GitHub UI (its "Details" link), e.g. the release run.',
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})

	-- gh substitutes {owner}/{repo} from the repository it infers when no explicit
	-- owner/name is given, so this doubles as the default.
	local function repoPath(): string
		local repo = parser:get("repo")
		return if repo and repo ~= "" then repo else "{owner}/{repo}"
	end

	-- The commit to mark, or nil when the branch does not exist yet (no publish PR
	-- has been opened), which is a no-op rather than an error. An explicit --sha
	-- wins; otherwise the branch head is resolved, defaulting to the publish branch.
	local function resolveSha(): string?
		local sha = parser:get("sha")
		if sha and sha ~= "" then
			return sha
		end

		local branch = parser:get("branch")
		if not branch or branch == "" then
			branch = publishLockStatus.DEFAULT_PUBLISH_BRANCH
		end

		local ref = process.run({
			config.ghCmd,
			"api",
			`repos/{repoPath()}/git/ref/heads/{branch}`,
			"--jq",
			".object.sha",
		})
		if not ref.ok then
			if publishLockStatus.isMissingRefError(ref.stderr) then
				print(`No {branch} branch to mark; skipping.`)
				return nil
			end
			error(`Could not resolve the {branch} head: {ref.stderr}`)
		end

		return chomp(ref.stdout)
	end

	local function run()
		local sha = resolveSha()
		if not sha then
			return
		end

		local command = { config.ghCmd }
		local args = publishLockStatus.buildStatusArgs({
			repo = repoPath(),
			sha = sha,
			state = options.state,
			context = publishLockStatus.DEFAULT_CONTEXT,
			description = publishLockStatus.describe(options.state),
			url = parser:get("url"),
		})
		table.move(args, 1, #args, #command + 1, command)

		local posted = process.run(command, { stdio = "inherit" })
		assert(posted.ok, posted.stderr)

		print(`Set {publishLockStatus.DEFAULT_CONTEXT} = {options.state} on {sha}`)
	end

	return {
		run = run,
		title = options.title,
		summary = options.summary,
		parser = parser,
	}
end

return createPublishLockCommand
