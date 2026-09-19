local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseCategories = require("@root/release/parseCategories")

local function readCategories(): { string }?
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseCategories(fs.readFileToString(configPath))
end

return readCategories
