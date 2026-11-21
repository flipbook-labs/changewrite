local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

local constants = require("@root/release/constants")
local renderLuauConfig = require("@root/release/renderLuauConfig")

-- The settings whose names changed from snake_case to camelCase. Only
-- top-level settings are renamed, since a kind's name is the repo's own and
-- keeps its spelling.
local RENAMED_SETTINGS: { [string]: string } = {
	max_summary_length = "maxSummaryLength",
	unreleased_changes = "unreleasedChanges",
}

-- A version target that named changewrite.toml would point at a deleted file
-- once the conversion removes it, so it names changewrite.luau instead. Its
-- pattern goes too, since changewrite.luau has a default one.
local function retargetConfigFile(target: unknown)
	if typeof(target) ~= "table" then
		return
	end
	local fields = target :: { [string]: unknown }
	if fields.file == constants.LEGACY_CONFIG_FILE then
		fields.file = constants.CONFIG_FILE
		fields.pattern = nil
	end
end

-- Converts a changewrite.toml to the source of the equivalent changewrite.luau.
-- TOML comments and the file's own ordering don't survive the conversion.
local function convertTomlConfig(text: string): string
	local config: { [string]: unknown } = {}
	for key, value in toml.deserialize(text) do
		config[RENAMED_SETTINGS[key] or key] = value
	end

	local version = config.version
	if typeof(version) == "table" then
		local versionConfig = version :: { [string]: unknown }
		retargetConfigFile(versionConfig)
		local mirror = versionConfig.mirror
		if typeof(mirror) == "table" and #(mirror :: { unknown }) > 0 then
			for _, target in mirror :: { unknown } do
				retargetConfigFile(target)
			end
		else
			retargetConfigFile(mirror)
		end
	end

	return renderLuauConfig(config)
end

return convertTomlConfig
