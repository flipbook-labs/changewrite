local fs = require("@std/fs")

local constants = require("@root/release/constants")
local prependSection = require("@root/release/prependSection")
local removeUnreleasedChanges = require("@root/release/removeUnreleasedChanges")
local renderChangelogSection = require("@root/release/renderChangelogSection")
local types = require("@root/release/types")
local writeVersion = require("@root/release/writeVersion")

type UnreleasedChange = types.UnreleasedChange

local CHANGELOG_FILE = constants.CHANGELOG_FILE
local DEFAULT_HEADER = "# Changelog\n\nAll notable changes to this project will be documented in this file."

local function prepareReleaseFiles(nextVersion: string, changes: { UnreleasedChange }): { string }
	local changedFiles = writeVersion(nextVersion)

	if #changes == 0 then
		return changedFiles
	end

	local section = renderChangelogSection(nextVersion, changes)
	local existing = if fs.exists(CHANGELOG_FILE) then fs.readFileToString(CHANGELOG_FILE) else DEFAULT_HEADER
	fs.writeStringToFile(CHANGELOG_FILE, prependSection(existing, section))
	table.insert(changedFiles, CHANGELOG_FILE)

	local consumed: { string } = {}
	for _, change in changes do
		table.insert(consumed, change.file)
	end
	removeUnreleasedChanges(consumed)
	for _, file in consumed do
		table.insert(changedFiles, file)
	end

	return changedFiles
end

return prepareReleaseFiles
