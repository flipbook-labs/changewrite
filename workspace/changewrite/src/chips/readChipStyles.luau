local parseChipStyles = require("@root/chips/parseChipStyles")
local readConfig = require("@root/release/readConfig")
local types = require("@root/chips/types")

local function readChipStyles(): { types.ChipStyle }
	return parseChipStyles(readConfig())
end

return readChipStyles
