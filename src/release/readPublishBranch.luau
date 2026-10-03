local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parsePublishBranch = require("@root/release/parsePublishBranch")

local function readPublishBranch(): string
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parsePublishBranch(fs.readFileToString(configPath))
end

return readPublishBranch
