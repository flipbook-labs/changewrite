local fs = require("@std/fs")
local path = require("@std/path")

local assertConfigVersionLiteral = require("@root/release/assertConfigVersionLiteral")
local constants = require("@root/release/constants")
local readVersionConfig = require("@root/release/readVersionConfig")
local writeTargetVersion = require("@root/release/writeTargetVersion")

local function writeVersion(nextVersion: string): { path.Path }
	local config = readVersionConfig()
	local source = config.source
	-- Checked before any file changes, so a bump that would rewrite the wrong
	-- value fails without touching changewrite.luau or the mirrors.
	if
		tostring(source.file) == constants.CONFIG_FILE
		and source.pattern == constants.DEFAULT_PATTERNS[constants.CONFIG_FILE]
	then
		assertConfigVersionLiteral(fs.readFileToString(source.file), config.current)
	end

	local changedFiles = { source.file }
	writeTargetVersion(source, nextVersion)

	for _, mirror in config.mirrors do
		writeTargetVersion(mirror, nextVersion)
		table.insert(changedFiles, mirror.file)
	end

	return changedFiles
end

return writeVersion
