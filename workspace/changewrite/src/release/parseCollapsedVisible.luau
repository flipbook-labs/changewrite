local types = require("@root/release/types")

local DEFAULT_COLLAPSED_VISIBLE = 5

-- How many entries a collapsed category shows before folding the rest under a
-- toggle. Zero folds every entry, and `math.huge` shows them all.
local function parseCollapsedVisible(config: types.Config): number
	if config.collapsedVisible == nil then
		return DEFAULT_COLLAPSED_VISIBLE
	end
	assert(
		typeof(config.collapsedVisible) == "number"
			and (
				config.collapsedVisible == math.huge
				or (config.collapsedVisible >= 0 and config.collapsedVisible % 1 == 0)
			),
		"`collapsedVisible` must be a whole number of at least 0, or `math.huge`"
	)
	return config.collapsedVisible
end

return parseCollapsedVisible
