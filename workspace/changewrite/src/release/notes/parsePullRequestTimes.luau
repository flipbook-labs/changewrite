-- Reads `git log --format="%ct %s"` output and returns when each pull request
-- merged, keyed by PR number, in seconds since the Unix epoch. A squash merge's
-- subject ends with the number, such as "Add a thing (#42)", and a merge
-- commit's starts with "Merge pull request #42". Commits with any other subject
-- are skipped, even when the number appears somewhere in them.
--
-- Git lists commits newest first, so each line for a PR replaces the one above
-- it, and the oldest commit wins. That's the one that merged the PR. A newer
-- commit with the same subject, such as a cherry-pick, doesn't count.
local function parsePullRequestTimes(log: string): { [number]: number }
	local times: { [number]: number } = {}
	for line in log:gmatch("[^\n]+") do
		local timestamp, subject = line:match("^(%d+) (.-)%s*$")
		if timestamp and subject then
			local number = subject:match("%(#(%d+)%)$") or subject:match("^Merge pull request #(%d+)")
			local pr = tonumber(number)
			if pr then
				times[pr] = tonumber(timestamp) :: number
			end
		end
	end
	return times
end

return parsePullRequestTimes
