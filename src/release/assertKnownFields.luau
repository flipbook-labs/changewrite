local toml = require("@batteries/toml")

local function assertKnownFields(
	value: { [string]: toml.TomlValue },
	allowedFields: { [string]: boolean },
	context: string
): ()
	for field in value do
		assert(allowedFields[field], `Unknown field "{field}" in {context}`)
	end
end

return assertKnownFields
