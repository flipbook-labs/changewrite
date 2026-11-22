local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseKindNames = require("@root/release/parseKindNames")

local function readKindNames(): { string }
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseKindNames(fs.readFileToString(configPath))
end

return readKindNames
