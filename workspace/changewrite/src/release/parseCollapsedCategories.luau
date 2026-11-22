local types = require("@root/release/types")

local function parseCollapsedCategories(config: types.Config): { string }
	local value = config.collapsed
	if value == nil then
		return {}
	end
	assert(typeof(value) == "table", "`collapsed` must be a list of category names")

	local configured = config.categories
	local configuredCategories = if typeof(configured) == "table" then configured :: { unknown } else nil

	local collapsed: { string } = {}
	for _, category in value :: { unknown } do
		assert(typeof(category) == "string" and category ~= "", "`collapsed` must be a list of category names")
		if configuredCategories then
			assert(
				table.find(configuredCategories, category) ~= nil,
				`Collapsed category "{category}" is not listed in \`categories\``
			)
		end
		table.insert(collapsed, category)
	end
	return collapsed
end

return parseCollapsedCategories
