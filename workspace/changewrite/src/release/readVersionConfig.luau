local parseVersionConfig = require("@root/release/parseVersionConfig")
local readConfig = require("@root/release/readConfig")
local types = require("@root/release/types")

type VersionConfig = types.VersionConfig

local function readVersionConfig(): VersionConfig
	return parseVersionConfig(readConfig())
end

return readVersionConfig
