local fs = require("@std/fs")

local getVersionPattern = require("@root/release/getVersionPattern")
local replaceCapturedVersion = require("@root/release/replaceCapturedVersion")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function writeTargetVersion(target: VersionTarget, nextVersion: string): ()
	local content = fs.readFileToString(target.file)
	local updated = replaceCapturedVersion(content, getVersionPattern(target), nextVersion, target.file)
	fs.writeStringToFile(target.file, updated)
end

return writeTargetVersion
