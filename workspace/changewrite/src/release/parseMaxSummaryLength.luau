local types = require("@root/release/types")

local DEFAULT_MAX_SUMMARY_LENGTH = 140

local function parseMaxSummaryLength(config: types.Config): number
	local value = config.maxSummaryLength
	if value == nil then
		return DEFAULT_MAX_SUMMARY_LENGTH
	end
	assert(
		typeof(value) == "number" and value >= 1 and value % 1 == 0,
		"`maxSummaryLength` must be a positive whole number"
	)
	return value
end

return parseMaxSummaryLength
