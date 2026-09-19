local toml = require("@batteries/toml")

local constants = require("@root/release/constants")
local parseVersionTarget = require("@root/release/parseVersionTarget")
local readTomlString = require("@root/release/readTomlString")
local types = require("@root/release/types")
local validateConfigFields = require("@root/release/validateConfigFields")

type VersionConfig = types.VersionConfig
type VersionTarget = types.VersionTarget

local function parseVersionConfig(text: string): VersionConfig
	validateConfigFields(text)
	local parsed = toml.deserialize(text)

	local version = parsed.version
	local versionConfig: { [string]: toml.TomlValue } = if typeof(version) == "table"
		then version :: { [string]: toml.TomlValue }
		else {}

	local file = readTomlString(versionConfig.file)
	local source: VersionTarget = if file
		then {
			file = file,
			pattern = readTomlString(versionConfig.pattern),
		}
		else {
			file = constants.CONFIG_FILE,
			pattern = constants.DEFAULT_PATTERNS[constants.CONFIG_FILE],
		}

	local mirrors: { VersionTarget } = {}
	local mirror = versionConfig.mirror
	local single = parseVersionTarget(mirror)
	if single then
		table.insert(mirrors, single)
	elseif typeof(mirror) == "table" then
		for _, entry in mirror :: { toml.TomlValue } do
			local target = parseVersionTarget(entry)
			if target then
				table.insert(mirrors, target)
			end
		end
	end

	return {
		current = readTomlString(versionConfig.current),
		source = source,
		mirrors = mirrors,
		unreleasedChangesDir = readTomlString(parsed.unreleased_changes) or constants.DEFAULT_UNRELEASED_CHANGES_DIR,
	}
end

return parseVersionConfig
