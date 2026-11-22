local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local process = require("@std/process")

local applyUnlock = require("@root/release/applyUnlock")
local buildStatusArgs = require("@root/release/buildStatusArgs")
local chomp = require("@root/chomp")
local config = require("@root/config")
local constants = require("@root/release/constants")
local readPublishBranch = require("@root/release/readPublishBranch")
local resolveBaseBranch = require("@root/release/resolveBaseBranch")
local types = require("@root/cli/types")

local function describe(state: buildStatusArgs.State): string
	if state == "failure" then
		return "Updating the release branch..."
	end

	return "Ready to publish"
end

local function createPublishLockCommand(options: {
	title: string,
	summary: string,
	state: buildStatusArgs.State,
}): types.Command
	local isUnlock = options.state == "success"

	local parser = cli.parser()
	parser:add("branch", "option", {
		help = "Post the status to this branch's head commit. Defaults to `release.branch` from changewrite.luau.",
	})
	parser:add("sha", "option", {
		help = "Post the status to this exact commit instead of a branch head. Takes precedence over --branch.",
	})
	if isUnlock then
		parser:add("base-sha", "option", {
			help = "The full base-branch commit the publish branch was refreshed from. When the base branch has moved past it, lock instead of unlocking.",
		})
		parser:add("base-branch", "option", {
			help = "The branch --base-sha belongs to. Defaults to the pull request's base branch on GitHub Actions, otherwise the repository's default branch.",
		})
	end
	parser:add("repo", "option", {
		help = "Repository as owner/name. Defaults to the repository gh infers.",
	})
	parser:add("url", "option", {
		help = 'URL the status badge links to in the GitHub UI (its "Details" link), e.g. the release run.',
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})

	-- The action forwards its inputs unconditionally, so an empty value means unset.
	local function getOption(name: string): string?
		local value = parser:get(name)
		return if value and value ~= "" then value else nil
	end

	-- gh substitutes {owner}/{repo} from the repository it infers when no
	-- explicit owner/name is given, so this doubles as the default.
	local function resolveRepo(): string
		return getOption("repo") or "{owner}/{repo}"
	end

	local function readBranchHead(branch: string): string?
		local ref = process.run({
			config.ghCmd,
			"api",
			`repos/{resolveRepo()}/git/ref/heads/{branch}`,
			"--jq",
			".object.sha",
		})
		if not ref.ok then
			-- gh exits non-zero for any non-2xx response, so tell a missing branch
			-- apart from a real failure like a network error or a 5xx, which must
			-- fail loudly. A missing ref is a 404.
			if ref.stderr:find("HTTP 404", 1, true) then
				return nil
			end
			error(`Could not resolve the {branch} head: {ref.stderr}`)
		end

		return chomp(ref.stdout)
	end

	local function resolveSha(): string?
		local sha = getOption("sha")
		if sha then
			return sha
		end

		local branch = getOption("branch") or readPublishBranch()
		local head = readBranchHead(branch)
		if not head then
			-- No publish PR has been opened yet, so there is nothing to mark.
			print(`No {branch} branch to mark, skipping.`)
		end
		return head
	end

	local function post(sha: string, state: buildStatusArgs.State, description: string)
		local command = { config.ghCmd }
		local args = buildStatusArgs({
			repo = resolveRepo(),
			sha = sha,
			state = state,
			context = constants.PUBLISH_LOCK_CONTEXT,
			description = description,
			url = getOption("url"),
		})
		table.move(args, 1, #args, #command + 1, command)

		local posted = process.run(command, { stdio = "inherit" })
		assert(posted.ok, posted.stderr)

		print(`Set {constants.PUBLISH_LOCK_CONTEXT} = {state} on {sha}`)
	end

	local function unlock(sha: string)
		local isExplicitSha = getOption("sha") ~= nil
		local publishBranch = readPublishBranch()
		local publishHead = if isExplicitSha then readBranchHead(publishBranch) else nil

		local baseSha = getOption("base-sha")
		local baseBranch: string? = nil
		if baseSha then
			baseBranch = getOption("base-branch") or resolveBaseBranch()
			assert(baseBranch, "Could not determine the base branch. Pass it with --base-branch.")
		end

		local isPosted = false
		applyUnlock({
			sha = sha,
			isExplicitSha = isExplicitSha,
			publishHead = publishHead,
			baseSha = baseSha,
			-- applyUnlock only reads the base when baseSha is set, which is
			-- exactly when baseBranch was resolved above.
			readBaseHead = function()
				local branch = baseBranch :: string
				local head = readBranchHead(branch)
				assert(head, `The {branch} base branch does not exist.`)
				return head
			end,
			post = function(state)
				isPosted = true
				if state == "failure" then
					print(`{baseBranch} moved past {baseSha} since the refresh, locking.`)
					post(sha, state, `{baseBranch} moved, waiting for the next release run`)
				else
					post(sha, state, describe(state))
				end
			end,
		})

		if not isPosted then
			print(`{sha} is the {publishBranch} head, which the release run owns, skipping.`)
		end
	end

	local function run()
		local sha = resolveSha()
		if not sha then
			return
		end

		if isUnlock then
			unlock(sha)
		else
			post(sha, options.state, describe(options.state))
		end
	end

	return {
		run = run,
		title = options.title,
		summary = options.summary,
		parser = parser,
	}
end

return createPublishLockCommand
