local fs = require("@std/fs")

local getVersionPattern = require("@root/release/getVersionPattern")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function readTargetVersion(target: VersionTarget): string
	local file = target.file
	local content = fs.readFileToString(file)
	local version = content:match(getVersionPattern(target))
	assert(version, `Could not find a version in {file}`)
	return version
end

return readTargetVersion
