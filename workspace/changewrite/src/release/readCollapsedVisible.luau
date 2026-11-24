local parseCollapsedVisible = require("@root/release/parseCollapsedVisible")
local readConfig = require("@root/release/readConfig")

local function readCollapsedVisible(): number
	return parseCollapsedVisible(readConfig())
end

return readCollapsedVisible
