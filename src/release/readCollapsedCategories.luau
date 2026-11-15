local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseCollapsedCategories = require("@root/release/parseCollapsedCategories")

local function readCollapsedCategories(): { string }
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseCollapsedCategories(fs.readFileToString(configPath))
end

return readCollapsedCategories
