local fs = require("@std/fs")
local path = require("@std/path")

local parseCategories = require("@root/release/parseCategories")
local versionSource = require("@root/release/versionSource")

local function readCategories(): { string }?
	local configPath = path.resolve(versionSource.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {versionSource.CONFIG_FILE} in the current directory`)
	return parseCategories(fs.readFileToString(configPath))
end

return readCategories
