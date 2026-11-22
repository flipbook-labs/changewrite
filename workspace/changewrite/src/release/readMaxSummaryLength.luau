local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseMaxSummaryLength = require("@root/release/parseMaxSummaryLength")

local function readMaxSummaryLength(): number
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseMaxSummaryLength(fs.readFileToString(configPath))
end

return readMaxSummaryLength
