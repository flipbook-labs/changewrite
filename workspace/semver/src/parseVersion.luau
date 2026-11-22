-- Split a semver string into its numeric major, minor, and patch components.
local function parseVersion(version: string): (number, number, number)
	local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
	assert(major and minor and patch, `Invalid semver version: "{version}"`)
	return tonumber(major) :: number, tonumber(minor) :: number, tonumber(patch) :: number
end

return parseVersion
