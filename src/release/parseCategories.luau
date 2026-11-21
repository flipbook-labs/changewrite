local types = require("@root/release/types")

local function parseCategories(config: types.Config): { string }?
	local value = config.categories
	if value == nil then
		return nil
	end
	assert(typeof(value) == "table", "`categories` must be a non-empty list of strings")

	local categoryValues = value :: { unknown }
	local categories = {}
	local seen = {}
	for _, category in categoryValues do
		assert(typeof(category) == "string" and category ~= "", "`categories` must be a non-empty list of strings")
		assert(not seen[category], `Duplicate changelog category "{category}"`)
		seen[category] = true
		table.insert(categories, category)
	end
	assert(#categories > 0 and #categories == #categoryValues, "`categories` must be a non-empty list of strings")
	return categories
end

return parseCategories
