-- Split a semver string into its numeric major, minor, and patch components.
local function parseVersion(version: string): (number, number, number)
	local majorText, minorText, patchText = version:match("^(%d+)%.(%d+)%.(%d+)$")
	local major, minor, patch = tonumber(majorText), tonumber(minorText), tonumber(patchText)
	assert(major and minor and patch, `Invalid semver version: "{version}"`)
	return major, minor, patch
end

return parseVersion
