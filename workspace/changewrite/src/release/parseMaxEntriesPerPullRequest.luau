local types = require("@root/release/types")

local DEFAULT_MAX_ENTRIES_PER_PULL_REQUEST = 1

--[[
	How many changelog entries one pull request may add, from
	`maxEntriesPerPullRequest` in changewrite.luau. A pull request squash-merges
	into one commit, and two entries for it would read in the release as two
	separate changes, so the default is one. `math.huge` removes the limit.
]]
local function parseMaxEntriesPerPullRequest(config: types.Config): number
	if config.maxEntriesPerPullRequest == nil then
		return DEFAULT_MAX_ENTRIES_PER_PULL_REQUEST
	end
	assert(
		typeof(config.maxEntriesPerPullRequest) == "number"
			and (
				config.maxEntriesPerPullRequest == math.huge
				or (config.maxEntriesPerPullRequest >= 1 and config.maxEntriesPerPullRequest % 1 == 0)
			),
		"`maxEntriesPerPullRequest` must be a positive whole number, or `math.huge`"
	)
	return config.maxEntriesPerPullRequest
end

return parseMaxEntriesPerPullRequest
