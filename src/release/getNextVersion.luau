local parseVersion = require("@root/release/parseVersion")
local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

-- Compute the next version. `major` resets the minor and patch (x.y.z ->
-- (x+1).0.0); `minor` resets the patch (x.y.z -> x.(y+1).0); `patch` increments
-- the patch (x.y.z -> x.y.(z+1)).
local function getNextVersion(version: string, kind: VersionComponent): string
	local major, minor, patch = parseVersion(version)
	if kind == "major" then
		return `{major + 1}.0.0`
	elseif kind == "patch" then
		return `{major}.{minor}.{patch + 1}`
	end
	return `{major}.{minor + 1}.0`
end

return getNextVersion
