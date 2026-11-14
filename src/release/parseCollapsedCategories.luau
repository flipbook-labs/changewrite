local toml = require("@batteries/toml")

local function parseCollapsedCategories(text: string): { string }
	local parsed = toml.deserialize(text)
	local value = parsed.collapsed
	if value == nil then
		return {}
	end
	assert(typeof(value) == "table", "`collapsed` must be an array of category names")

	local configured = parsed.categories
	local configuredCategories = if typeof(configured) == "table" then configured :: { toml.TomlValue } else nil

	local collapsed: { string } = {}
	for _, category in value :: { toml.TomlValue } do
		assert(typeof(category) == "string" and category ~= "", "`collapsed` must be an array of category names")
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
