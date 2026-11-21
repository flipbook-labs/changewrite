local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

local DEFAULT_MAX_SUMMARY_LENGTH = 140

local function parseMaxSummaryLength(text: string): number
	local value = toml.deserialize(text).max_summary_length
	if value == nil then
		return DEFAULT_MAX_SUMMARY_LENGTH
	end
	assert(
		typeof(value) == "number" and value >= 1 and value % 1 == 0,
		"`max_summary_length` must be a positive whole number"
	)
	return value
end

return parseMaxSummaryLength
