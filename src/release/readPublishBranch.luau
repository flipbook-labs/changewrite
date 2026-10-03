local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parsePublishBranch = require("@root/release/parsePublishBranch")

local function readPublishBranch(): string
	-- Without a config file every setting takes its default, including the
	-- publish branch the action and publish-lock fall back to.
	local configPath = path.resolve(constants.CONFIG_FILE)
	if not fs.exists(configPath) then
		return constants.PUBLISH_BRANCH
	end
	return parsePublishBranch(fs.readFileToString(configPath))
end

return readPublishBranch
