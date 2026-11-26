local types = require("@root/release/types")

local function parseCollapsedCategories(config: types.Config): { string }
	if config.collapsed == nil then
		return {}
	end
	assert(typeof(config.collapsed) == "table", "`collapsed` must be a list of category names")

	local configuredCategories = if typeof(config.categories) == "table" then config.categories :: { unknown } else nil

	local collapsed: { string } = {}
	for _, category in config.collapsed :: { unknown } do
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
