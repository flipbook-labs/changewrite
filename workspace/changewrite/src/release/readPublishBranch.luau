local constants = require("@root/release/constants")
local parsePublishBranch = require("@root/release/parsePublishBranch")
local readOptionalConfig = require("@root/release/readOptionalConfig")

local function readPublishBranch(): string
	-- Without a config file every setting takes its default, including the
	-- publish branch the action and publish-lock fall back to.
	local config = readOptionalConfig()
	if not config then
		return constants.PUBLISH_BRANCH
	end
	return parsePublishBranch(config)
end

return readPublishBranch
