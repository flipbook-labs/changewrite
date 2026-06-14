local getNextVersion = require("@root/release/getNextVersion")

type VersionComponent = getNextVersion.VersionComponent

-- Validate a CLI-supplied semver component, erroring on anything that isn't
-- `major`, `minor`, or `patch` (including a missing value). Shared by the
-- commands that take a `--bump` option so they reject bad input the same way.
local function parseVersionComponent(value: string?): VersionComponent
	if value == "major" or value == "minor" or value == "patch" then
		return value
	end
	error(`Unknown version component "{value}"`)
end

return parseVersionComponent
