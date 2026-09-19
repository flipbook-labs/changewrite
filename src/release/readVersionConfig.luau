local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseVersionConfig = require("@root/release/parseVersionConfig")
local types = require("@root/release/types")

type VersionConfig = types.VersionConfig

local function readVersionConfig(): VersionConfig
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseVersionConfig(fs.readFileToString(configPath))
end

return readVersionConfig
