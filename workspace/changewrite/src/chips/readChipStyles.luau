local chips = require("@chips")
local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseChipStyles = require("@root/chips/parseChipStyles")

local function readChipStyles(): { chips.ChipStyle }
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseChipStyles(fs.readFileToString(configPath))
end

return readChipStyles
