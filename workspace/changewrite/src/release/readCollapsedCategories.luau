local parseCollapsedCategories = require("@root/release/parseCollapsedCategories")
local readConfig = require("@root/release/readConfig")

local function readCollapsedCategories(): { string }
	return parseCollapsedCategories(readConfig())
end

return readCollapsedCategories
