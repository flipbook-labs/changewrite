local types = require("@root/release/types")

-- The names of the kinds changewrite.luau configures, which entries may use in
-- their `kind` field. `parseChipStyles` validates each kind's fields.
local function parseKindNames(config: types.Config): { string }
	local kinds = config.kind
	if kinds == nil then
		return {}
	end
	assert(typeof(kinds) == "table", "`kind` must be a table of kinds, keyed by name")

	local names: { string } = {}
	for name in kinds :: { [string]: unknown } do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return parseKindNames
