local getNextVersion = require("@root/release/getNextVersion")
local placeholderVersion = require("@root/release/placeholderVersion")
local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

local FIRST_RELEASE = "0.1.0"
local FIRST_MAJOR_RELEASE = "1.0.0"

-- Decide which version a release PR should target. A tagged current version
-- steps forward by the pending bump; an untagged one is still being prepared,
-- so it stays put. The exception is the 0.0.0 placeholder: a repo with no
-- releases yet bootstraps to 0.1.0 (or straight to 1.0.0 when a major change
-- is pending) rather than releasing 0.0.0 itself.
local function resolveNextVersion(current: string, tagExists: boolean, bump: VersionComponent?): string
	if current == placeholderVersion then
		return if bump == "major" then FIRST_MAJOR_RELEASE else FIRST_RELEASE
	end
	if tagExists and bump then
		return getNextVersion(current, bump)
	end
	return current
end

return resolveNextVersion
