local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

-- Validate a semver component, erroring on anything that isn't `major`, `minor`,
-- or `patch` (including a missing value). Used to check the `bump` field of each
-- unreleased change so bad input is rejected the same way everywhere.
local function parseVersionComponent(value: string?): VersionComponent
	if value == "major" or value == "minor" or value == "patch" then
		return value
	end
	error(`Unknown version component "{value}"`)
end

return parseVersionComponent
