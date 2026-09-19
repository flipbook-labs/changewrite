local constants = require("@root/release/constants")
local readTargetVersion = require("@root/release/readTargetVersion")
local readVersionConfig = require("@root/release/readVersionConfig")

local function getCurrentVersion(): string
	local config = readVersionConfig()
	if config.source.file == constants.CONFIG_FILE and config.current then
		return config.current
	end
	return readTargetVersion(config.source)
end

return getCurrentVersion
