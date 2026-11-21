local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

local renderLuauConfig = require("@root/release/renderLuauConfig")

-- The settings whose names changed from snake_case to camelCase. Only
-- top-level settings are renamed, since a kind's name is the repo's own and
-- keeps its spelling.
local RENAMED_SETTINGS: { [string]: string } = {
	max_summary_length = "maxSummaryLength",
	unreleased_changes = "unreleasedChanges",
}

-- Converts a changewrite.toml to the source of the equivalent changewrite.luau.
-- TOML comments and the file's own ordering don't survive the conversion.
local function convertTomlConfig(text: string): string
	local config: { [string]: unknown } = {}
	for key, value in toml.deserialize(text) do
		config[RENAMED_SETTINGS[key] or key] = value
	end
	return renderLuauConfig(config)
end

return convertTomlConfig
