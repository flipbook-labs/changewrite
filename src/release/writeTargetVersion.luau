local fs = require("@std/fs")
local path = require("@std/path")

local getVersionPattern = require("@root/release/getVersionPattern")
local replaceCapturedVersion = require("@root/release/replaceCapturedVersion")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function writeTargetVersion(target: VersionTarget, nextVersion: string): ()
	local file = path.resolve(target.file)
	local content = fs.readFileToString(file)
	local updated = replaceCapturedVersion(content, getVersionPattern(target), nextVersion, tostring(file))
	fs.writeStringToFile(file, updated)
end

return writeTargetVersion
