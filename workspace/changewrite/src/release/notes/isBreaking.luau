local ChangeFlag = require("@root/release/ChangeFlag")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function isBreaking(entry: UnreleasedChange): boolean
	return table.find(entry.flags, ChangeFlag.Breaking) ~= nil
end

return isBreaking
