local VersionComponent = require("./VersionComponent")
local types = require("./types")

type VersionComponent = types.VersionComponent

local function parseVersionComponent(value: string?): VersionComponent
	if value == VersionComponent.Major or value == VersionComponent.Minor or value == VersionComponent.Patch then
		return value :: VersionComponent
	end
	error(`Unknown version component "{value}"`)
end

return parseVersionComponent
