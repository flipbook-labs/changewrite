local parseVersion = require("./parseVersion")

-- Pick the highest semver from a non-empty list, comparing major, then minor,
-- then patch.
local function pickHighestVersion(versions: { string }): string
	local highest = versions[1]
	assert(highest, "pickHighestVersion requires at least one version")

	local hMajor, hMinor, hPatch = parseVersion(highest)
	for i = 2, #versions do
		local major, minor, patch = parseVersion(versions[i])
		if major > hMajor or (major == hMajor and (minor > hMinor or (minor == hMinor and patch > hPatch))) then
			highest, hMajor, hMinor, hPatch = versions[i], major, minor, patch
		end
	end

	return highest
end

return pickHighestVersion
