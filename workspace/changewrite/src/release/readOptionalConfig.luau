local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseConfig = require("@root/release/parseConfig")
local types = require("@root/release/types")

type Config = types.Config

-- Reads changewrite.luau from the current directory, or returns nil when the
-- repo has none. A leftover changewrite.toml fails instead, even next to a
-- changewrite.luau, so a repo never keeps two configs that disagree.
local function readOptionalConfig(): Config?
	assert(
		not fs.exists(path.resolve(constants.LEGACY_CONFIG_FILE)),
		`Changewrite reads {constants.CONFIG_FILE} instead of {constants.LEGACY_CONFIG_FILE}. Run \`changewrite check --fix\` to convert it.`
	)

	local configPath = path.resolve(constants.CONFIG_FILE)
	if not fs.exists(configPath) then
		return nil
	end
	return parseConfig(fs.readFileToString(configPath))
end

return readOptionalConfig
