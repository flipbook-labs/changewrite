local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

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
