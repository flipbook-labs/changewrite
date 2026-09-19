local toml = require("@batteries/toml")

local assertKnownFields = require("@root/release/assertKnownFields")

local TARGET_FIELDS: { [string]: boolean } = {
	file = true,
	pattern = true,
}

local function validateVersionTargetFields(value: toml.TomlValue, context: string): ()
	if typeof(value) == "table" then
		assertKnownFields(value :: { [string]: toml.TomlValue }, TARGET_FIELDS, context)
	end
end

return validateVersionTargetFields
