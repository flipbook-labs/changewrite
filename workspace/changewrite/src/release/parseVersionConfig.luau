local path = require("@std/path")

local constants = require("@root/release/constants")
local parseVersionTarget = require("@root/release/parseVersionTarget")
local readOptionalString = require("@root/release/readOptionalString")
local types = require("@root/release/types")

type Config = types.Config
type VersionConfig = types.VersionConfig
type VersionTarget = types.VersionTarget

local function parseVersionConfig(config: Config): VersionConfig
	local versionConfig: { [string]: unknown } = if typeof(config.version) == "table"
		then config.version :: { [string]: unknown }
		else {}

	local file = readOptionalString(versionConfig.file)
	local source: VersionTarget = if file
		then {
			file = path.parse(file),
			pattern = readOptionalString(versionConfig.pattern),
		}
		else {
			file = path.parse(constants.CONFIG_FILE),
			pattern = constants.DEFAULT_PATTERNS[constants.CONFIG_FILE],
		}

	local mirrors: { VersionTarget } = {}
	local mirror = versionConfig.mirror
	local single = parseVersionTarget(mirror)
	if single then
		table.insert(mirrors, single)
	elseif typeof(mirror) == "table" then
		for _, entry in mirror :: { unknown } do
			local target = parseVersionTarget(entry)
			if target then
				table.insert(mirrors, target)
			end
		end
	end

	return {
		current = readOptionalString(versionConfig.current),
		source = source,
		mirrors = mirrors,
		unreleasedChangesDir = path.parse(
			readOptionalString(config.unreleasedChanges) or constants.DEFAULT_UNRELEASED_CHANGES_DIR
		),
	}
end

return parseVersionConfig
