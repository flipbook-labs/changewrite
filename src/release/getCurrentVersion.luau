local versionSource = require("@root/release/versionSource")

local function getCurrentVersion(): string
	return versionSource.getCurrentVersion()
end

return getCurrentVersion
