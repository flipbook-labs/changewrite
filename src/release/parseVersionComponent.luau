local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

local function parseVersionComponent(value: string?): VersionComponent
	if value == "major" or value == "minor" or value == "patch" then
		return value
	end
	error(`Unknown version component "{value}"`)
end

return parseVersionComponent
