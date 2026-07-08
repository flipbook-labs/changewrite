local getNextVersion = require("@root/release/getNextVersion")
local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

-- Decide which version a release PR should target. A tagged current version
-- steps forward by the pending bump. An untagged one is the first release for
-- that version, so the configured version is authoritative and used verbatim --
-- the first release folds in the pending changes without bumping. A tagged
-- version with no pending bump likewise stays put.
local function resolveNextVersion(current: string, tagExists: boolean, bump: VersionComponent?): string
	if tagExists and bump then
		return getNextVersion(current, bump)
	end
	return current
end

return resolveNextVersion
