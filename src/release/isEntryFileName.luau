local constants = require("@root/release/constants")

local function isEntryFileName(name: string): boolean
	return name:match("%.luau$") ~= nil and name:lower() ~= constants.ENTRY_TYPES_FILE
end

return isEntryFileName
