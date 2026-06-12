local versionSource = require("@root/release/versionSource")

local function writeVersion(nextVersion: string): { string }
	return versionSource.writeVersion(nextVersion)
end

return writeVersion
