local assertKnownFields = require("@root/release/assertKnownFields")
local types = require("@root/release/types")
local validateVersionTargetFields = require("@root/release/validateVersionTargetFields")

type Config = types.Config

local TOP_LEVEL_FIELDS: { [string]: boolean } = {
	categories = true,
	collapsed = true,
	collapsedVisible = true,
	flag = true,
	kind = true,
	maxSummaryLength = true,
	release = true,
	unreleasedChanges = true,
	version = true,
}

local RELEASE_FIELDS: { [string]: boolean } = {
	branch = true,
}

local VERSION_FIELDS: { [string]: boolean } = {
	current = true,
	file = true,
	mirror = true,
	pattern = true,
}

local function validateConfigFields(config: Config): ()
	assertKnownFields(config, TOP_LEVEL_FIELDS, "changewrite.luau")

	if typeof(config.release) == "table" then
		assertKnownFields(config.release :: { [string]: unknown }, RELEASE_FIELDS, "`release`")
	end

	if typeof(config.version) ~= "table" then
		return
	end

	local versionConfig = config.version :: { [string]: unknown }
	assertKnownFields(versionConfig, VERSION_FIELDS, "`version`")

	local mirror = versionConfig.mirror
	if typeof(mirror) == "table" and #(mirror :: { unknown }) > 0 then
		for _, entry in mirror :: { unknown } do
			validateVersionTargetFields(entry, "a version mirror")
		end
	else
		validateVersionTargetFields(mirror, "version mirror")
	end
end

return validateConfigFields
