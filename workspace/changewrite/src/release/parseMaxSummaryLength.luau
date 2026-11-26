local types = require("@root/release/types")

local DEFAULT_MAX_SUMMARY_LENGTH = 140

local function parseMaxSummaryLength(config: types.Config): number
	if config.maxSummaryLength == nil then
		return DEFAULT_MAX_SUMMARY_LENGTH
	end
	assert(
		typeof(config.maxSummaryLength) == "number"
			and config.maxSummaryLength >= 1
			and config.maxSummaryLength % 1 == 0,
		"`maxSummaryLength` must be a positive whole number"
	)
	return config.maxSummaryLength
end

return parseMaxSummaryLength
