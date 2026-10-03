local toml = require("@batteries/toml")

local constants = require("@root/release/constants")

local function parsePublishBranch(text: string): string
	local release = toml.deserialize(text).release
	if typeof(release) ~= "table" then
		return constants.PUBLISH_BRANCH
	end

	local branch = (release :: { [string]: toml.TomlValue }).branch
	if branch == nil then
		return constants.PUBLISH_BRANCH
	end
	assert(typeof(branch) == "string" and branch ~= "", "`release.branch` must be a non-empty string")
	return branch
end

return parsePublishBranch
