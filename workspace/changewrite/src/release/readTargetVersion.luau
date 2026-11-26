local fs = require("@std/fs")

local getVersionPattern = require("@root/release/getVersionPattern")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function readTargetVersion(target: VersionTarget): string
	local content = fs.readFileToString(target.file)
	local version = content:match(getVersionPattern(target))
	assert(version, `Could not find a version in {target.file}`)
	return version
end

return readTargetVersion
