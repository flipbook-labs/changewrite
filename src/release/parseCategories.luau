local toml = require("@batteries/toml")

local function parseCategories(text: string): { string }?
	local value = toml.deserialize(text).categories
	if value == nil then
		return nil
	end
	assert(typeof(value) == "table", "`categories` must be a non-empty array of strings")

	local categoryValues = value :: { toml.TomlValue }
	local categories = {}
	local seen = {}
	for _, category in categoryValues do
		assert(typeof(category) == "string" and category ~= "", "`categories` must be a non-empty array of strings")
		assert(not seen[category], `Duplicate changelog category "{category}"`)
		seen[category] = true
		table.insert(categories, category)
	end
	assert(#categories > 0 and #categories == #categoryValues, "`categories` must be a non-empty array of strings")
	return categories
end

return parseCategories
