local toml = require("@batteries/toml")

local TARGET_FIELDS: { [string]: boolean } = {
	file = true,
	pattern = true,
}

local TOP_LEVEL_FIELDS: { [string]: boolean } = {
	categories = true,
	unreleased_changes = true,
	version = true,
}

local VERSION_FIELDS: { [string]: boolean } = {
	current = true,
	file = true,
	mirror = true,
	pattern = true,
}

local function assertKnownFields(
	value: { [string]: toml.TomlValue },
	allowedFields: { [string]: boolean },
	context: string
): ()
	for field in value do
		assert(allowedFields[field], `Unknown field "{field}" in {context}`)
	end
end

local function validateTarget(value: toml.TomlValue, context: string): ()
	if typeof(value) == "table" then
		assertKnownFields(value :: { [string]: toml.TomlValue }, TARGET_FIELDS, context)
	end
end

local function validateConfigFields(text: string): ()
	local parsed = toml.deserialize(text)
	assertKnownFields(parsed, TOP_LEVEL_FIELDS, "changewrite.toml")

	local version = parsed.version
	if typeof(version) ~= "table" then
		return
	end

	local versionConfig = version :: { [string]: toml.TomlValue }
	assertKnownFields(versionConfig, VERSION_FIELDS, "[version]")

	local mirror = versionConfig.mirror
	if typeof(mirror) == "table" and #(mirror :: { toml.TomlValue }) > 0 then
		for _, entry in mirror :: { toml.TomlValue } do
			validateTarget(entry, "a version mirror")
		end
	else
		validateTarget(mirror, "version mirror")
	end
end

return validateConfigFields
