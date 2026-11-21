local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

-- The names of the kinds changewrite.toml configures, which entries may use in
-- their `kind` field. `parseChipStyles` validates each kind's fields.
local function parseKindNames(text: string): { string }
	local kinds = toml.deserialize(text).kind
	if kinds == nil then
		return {}
	end
	assert(typeof(kinds) == "table", "`kind` must be a table of [kind.<name>] tables")

	local names: { string } = {}
	for name in kinds :: { [string]: toml.TomlValue } do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return parseKindNames
