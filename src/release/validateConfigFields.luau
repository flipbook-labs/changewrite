local toml = require("@batteries/toml")

local assertKnownFields = require("@root/release/assertKnownFields")
local validateVersionTargetFields = require("@root/release/validateVersionTargetFields")

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
			validateVersionTargetFields(entry, "a version mirror")
		end
	else
		validateVersionTargetFields(mirror, "version mirror")
	end
end

return validateConfigFields
