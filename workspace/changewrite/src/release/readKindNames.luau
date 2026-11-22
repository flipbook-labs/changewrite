local parseKindNames = require("@root/release/parseKindNames")
local readConfig = require("@root/release/readConfig")

local function readKindNames(): { string }
	return parseKindNames(readConfig())
end

return readKindNames
