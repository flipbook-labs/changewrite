local constants = require("@root/release/constants")
local readOptionalConfig = require("@root/release/readOptionalConfig")
local types = require("@root/release/types")

type Config = types.Config

local function readConfig(): Config
	local config = readOptionalConfig()
	assert(config, `Could not find {constants.CONFIG_FILE} in the current directory`)
	return config
end

return readConfig
