local cli = require("@batteries/cli")
local process = require("@std/process")

local buildStatusArgs = require("@root/release/buildStatusArgs")
local chomp = require("@root/chomp")
local config = require("@root/config")
local constants = require("@root/release/constants")
local types = require("@root/cli/types")

local function describe(state: buildStatusArgs.State): string
	if state == "failure" then
		return "A release run is updating the publish PR, so it is out of date"
	end

	return "The publish PR is up to date with its base branch"
end

local function createPublishLockCommand(options: {
	title: string,
	summary: string,
	state: buildStatusArgs.State,
}): types.Command
	local parser = cli.parser()
	parser:add("branch", "option", {
		help = `Post the status to this branch's head commit. Defaults to the publish branch ({constants.PUBLISH_BRANCH}).`,
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

	-- gh substitutes {owner}/{repo} from the repository it infers when no
	-- explicit owner/name is given, so this doubles as the default.
	local function repoPath(): string
		local repo = parser:get("repo")
		return if repo and repo ~= "" then repo else "{owner}/{repo}"
	end

	local function resolveSha(): string?
		local sha = parser:get("sha")
		if sha and sha ~= "" then
			return sha
		end

		local branch = parser:get("branch")
		if not branch or branch == "" then
			branch = constants.PUBLISH_BRANCH
		end

		local ref = process.run({
			config.ghCmd,
			"api",
			`repos/{repoPath()}/git/ref/heads/{branch}`,
			"--jq",
			".object.sha",
		})
		if not ref.ok then
			-- gh exits non-zero for any non-2xx response, so tell a missing branch
			-- (no publish PR opened yet, a no-op) apart from a real failure like a
			-- network error or a 5xx, which must fail loudly. A missing ref is a 404.
			if string.find(ref.stderr, "HTTP 404", 1, true) then
				print(`No {branch} branch to mark, skipping.`)
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
		local args = buildStatusArgs({
			repo = repoPath(),
			sha = sha,
			state = options.state,
			context = constants.PUBLISH_LOCK_CONTEXT,
			description = describe(options.state),
			url = parser:get("url"),
		})
		table.move(args, 1, #args, #command + 1, command)

		local posted = process.run(command, { stdio = "inherit" })
		assert(posted.ok, posted.stderr)

		print(`Set {constants.PUBLISH_LOCK_CONTEXT} = {options.state} on {sha}`)
	end

	return {
		run = run,
		title = options.title,
		summary = options.summary,
		parser = parser,
	}
end

return createPublishLockCommand
