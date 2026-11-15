local process = require("@std/process")

local config = require("@root/config")

-- Finds when a pull request merged, from the commit that merged it, in seconds
-- since the Unix epoch. A squash merge's subject ends with the number, such as
-- "Add a thing (#42)", and a merge commit's starts with "Merge pull request
-- #42". Returns nil when no commit in the current history merged it.
local function findPullRequestTime(pr: number): number?
	local result = process.run({
		config.gitCmd,
		"log",
		"--format=%ct %s",
		`--grep=#{pr}`,
	})
	if not result.ok then
		return nil
	end

	-- `--grep` matches the number anywhere in a commit's message, so only a
	-- subject in one of the two forms counts. The log lists newest first, so
	-- the last match is the earliest commit, the one that merged the PR. A
	-- later commit with the same subject, such as a cherry-pick, is skipped.
	local found: number?
	for line in result.stdout:gmatch("[^\n]+") do
		local timestamp, subject = line:match("^(%d+) (.-)%s*$")
		if timestamp and subject then
			local squashed = subject:match("%(#(%d+)%)$")
			local merged = subject:match("^Merge pull request #(%d+)")
			if tonumber(squashed) == pr or tonumber(merged) == pr then
				found = tonumber(timestamp)
			end
		end
	end
	return found
end

return findPullRequestTime
