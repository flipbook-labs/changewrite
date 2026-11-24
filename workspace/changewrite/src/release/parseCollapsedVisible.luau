local types = require("@root/release/types")

local DEFAULT_COLLAPSED_VISIBLE = 5

-- How many entries a collapsed category shows before folding the rest under a
-- toggle. Zero folds every entry, and `math.huge` shows them all.
local function parseCollapsedVisible(config: types.Config): number
	local value = config.collapsedVisible
	if value == nil then
		return DEFAULT_COLLAPSED_VISIBLE
	end
	assert(
		typeof(value) == "number" and (value == math.huge or (value >= 0 and value % 1 == 0)),
		"`collapsedVisible` must be a whole number of at least 0, or `math.huge`"
	)
	return value
end

return parseCollapsedVisible
