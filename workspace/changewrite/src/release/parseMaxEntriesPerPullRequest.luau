local types = require("@root/release/types")

local DEFAULT_MAX_ENTRIES_PER_PULL_REQUEST = 1

-- How many changelog entries one pull request may add, from
-- `maxEntriesPerPullRequest` in changewrite.luau. A pull request squash-merges
-- into one commit, and two entries for it would read in the release as two
-- separate changes, so the default is one. `math.huge` removes the limit.
local function parseMaxEntriesPerPullRequest(config: types.Config): number
	local value = config.maxEntriesPerPullRequest
	if value == nil then
		return DEFAULT_MAX_ENTRIES_PER_PULL_REQUEST
	end
	assert(
		typeof(value) == "number" and (value == math.huge or (value >= 1 and value % 1 == 0)),
		"`maxEntriesPerPullRequest` must be a positive whole number, or `math.huge`"
	)
	return value
end

return parseMaxEntriesPerPullRequest
