local process = require("@std/process")

local config = require("@root/config")
local parsePullRequestTimes = require("@root/release/notes/parsePullRequestTimes")

-- Finds when each of these pull requests merged, from the commits in the
-- current history, keyed by PR number. A PR with no merging commit in the
-- history is left out. It reads the log once for all of them, since a release
-- can have dozens of entries that name their PR.
local function findPullRequestTimes(prs: { number }): { [number]: number }
	if #prs == 0 then
		return {}
	end

	-- Git keeps a commit that matches any of the `--grep` patterns.
	local command = { config.gitCmd, "log", "--format=%ct %s" }
	for _, pr in prs do
		table.insert(command, `--grep=#{pr}`)
	end
	local result = process.run(command)
	if not result.ok then
		return {}
	end

	-- `--grep` also matches longer numbers and mentions anywhere in a message,
	-- so the parser can return PRs that weren't asked for. Callers look up only
	-- the ones they asked for, so those extras are harmless.
	return parsePullRequestTimes(result.stdout)
end

return findPullRequestTimes
