local constants = require("@root/release/constants")
local getVersionPattern = require("@root/release/getVersionPattern")
local types = require("@root/release/types")

type VersionConfig = types.VersionConfig
type VersionTarget = types.VersionTarget

-- The version targets, source or mirror, that a bump would update by
-- rewriting changewrite.luau with its default `current = "x.y.z"` pattern.
-- A target with its own pattern is left to that pattern.
local function findConfigVersionTargets(config: VersionConfig): { VersionTarget }
	local defaultPattern = constants.DEFAULT_PATTERNS[constants.CONFIG_FILE]
	local targets: { VersionTarget } = {}
	for _, target in { config.source, table.unpack(config.mirrors) } do
		if tostring(target.file) == constants.CONFIG_FILE and getVersionPattern(target) == defaultPattern then
			table.insert(targets, target)
		end
	end
	return targets
end

return findConfigVersionTargets
