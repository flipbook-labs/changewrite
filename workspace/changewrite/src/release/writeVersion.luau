local path = require("@std/path")

local readVersionConfig = require("@root/release/readVersionConfig")
local writeTargetVersion = require("@root/release/writeTargetVersion")

local function writeVersion(nextVersion: string): { path.Path }
	local config = readVersionConfig()
	local changedFiles = { config.source.file }
	writeTargetVersion(config.source, nextVersion)

	for _, mirror in config.mirrors do
		writeTargetVersion(mirror, nextVersion)
		table.insert(changedFiles, mirror.file)
	end

	return changedFiles
end

return writeVersion
