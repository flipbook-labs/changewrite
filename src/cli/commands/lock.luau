local cli = require("@batteries/cli")
local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")
local mergeLockStatus = require("@root/release/mergeLockStatus")
local types = require("@root/cli/types")

local title = "lock"
local summary = "Set the publish PR's merge-lock commit status."

local parser = cli.parser()
parser:add("state", "option", {
	help = "Status to post: success (unlocked) or failure (locked).",
	required = true,
})
parser:add("branch", "option", {
	help = "Post the status to this branch's head commit (e.g. the publish branch).",
})
parser:add("sha", "option", {
	help = "Post the status to this exact commit. Takes precedence over --branch.",
})
parser:add("repo", "option", {
	help = "Repository as owner/name. Defaults to the repository gh infers.",
})
parser:add("url", "option", {
	help = "Link the status points at, e.g. the release run.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function parseState(value: string): mergeLockStatus.State
	if value == "success" then
		return "success"
	end
	if value == "failure" then
		return "failure"
	end
	error(`--state must be "success" or "failure", got "{value}"`)
end

-- gh substitutes {owner}/{repo} from the repository it infers when no explicit
-- owner/name is given, so this doubles as the default.
local function repoPath(): string
	local repo = parser:get("repo")
	return if repo and repo ~= "" then repo else "{owner}/{repo}"
end

-- The commit to mark, or nil when a branch was named but does not exist yet
-- (no publish PR has been opened), which is a no-op rather than an error.
local function resolveSha(): string?
	local sha = parser:get("sha")
	if sha and sha ~= "" then
		return sha
	end

	local branch = assert(parser:get("branch"), "Pass --sha or --branch to locate the commit to mark")

	local ref = process.run({
		config.ghCmd,
		"api",
		`repos/{repoPath()}/git/ref/heads/{branch}`,
		"--jq",
		".object.sha",
	})
	if not ref.ok then
		print(`No {branch} branch to mark; skipping.`)
		return nil
	end

	return chomp(ref.stdout)
end

local function lock()
	local state = parseState(parser:get("state") :: string)

	local sha = resolveSha()
	if not sha then
		return
	end

	local command = { config.ghCmd }
	local args = mergeLockStatus.buildStatusArgs({
		repo = repoPath(),
		sha = sha,
		state = state,
		context = mergeLockStatus.DEFAULT_CONTEXT,
		description = mergeLockStatus.describe(state),
		url = parser:get("url"),
	})
	table.move(args, 1, #args, #command + 1, command)

	local posted = process.run(command, { stdio = "inherit" })
	assert(posted.ok, posted.stderr)

	print(`Set {mergeLockStatus.DEFAULT_CONTEXT} = {state} on {sha}`)
end

local command: types.Command = {
	run = lock,
	title = title,
	summary = summary,
	parser = parser,
}

return command
