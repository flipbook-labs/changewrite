local parseCategories = require("@root/release/parseCategories")
local readConfig = require("@root/release/readConfig")

local function readCategories(): { string }?
	return parseCategories(readConfig())
end

return readCategories
