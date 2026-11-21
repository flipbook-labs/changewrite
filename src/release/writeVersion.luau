local fs = require("@std/fs")
local path = require("@std/path")

local assertConfigVersionLiteral = require("@root/release/assertConfigVersionLiteral")
local findConfigVersionTargets = require("@root/release/findConfigVersionTargets")
local readVersionConfig = require("@root/release/readVersionConfig")
local writeTargetVersion = require("@root/release/writeTargetVersion")

local function writeVersion(nextVersion: string): { path.Path }
	local config = readVersionConfig()
	-- Checked before any file changes, so a bump that would rewrite the wrong
	-- value fails without touching changewrite.luau or the other targets.
	for _, target in findConfigVersionTargets(config) do
		assertConfigVersionLiteral(fs.readFileToString(target.file), config.current)
	end

	local changedFiles = { config.source.file }
	writeTargetVersion(config.source, nextVersion)

	for _, mirror in config.mirrors do
		writeTargetVersion(mirror, nextVersion)
		table.insert(changedFiles, mirror.file)
	end

	return changedFiles
end

return writeVersion
