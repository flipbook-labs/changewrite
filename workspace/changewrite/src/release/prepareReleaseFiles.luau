local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local prependSection = require("@root/release/prependSection")
local readReleaseSummary = require("@root/release/readReleaseSummary")
local removeUnreleasedChanges = require("@root/release/removeUnreleasedChanges")
local renderReleaseSection = require("@root/release/renderReleaseSection")
local types = require("@root/release/types")
local writeVersion = require("@root/release/writeVersion")

type UnreleasedChange = types.UnreleasedChange

local DEFAULT_HEADER = "# Changelog\n\nAll notable changes to this project will be documented in this file."

local function prepareReleaseFiles(nextVersion: string, changes: { UnreleasedChange }): { path.Path }
	local changedFiles = writeVersion(nextVersion)

	if #changes == 0 then
		return changedFiles
	end

	local section = renderReleaseSection(nextVersion, changes)
	local existing = if fs.exists(constants.CHANGELOG_FILE)
		then fs.readFileToString(constants.CHANGELOG_FILE)
		else DEFAULT_HEADER
	fs.writeStringToFile(constants.CHANGELOG_FILE, prependSection(existing, section))
	table.insert(changedFiles, path.parse(constants.CHANGELOG_FILE))

	local consumed: { path.Path } = {}
	for _, change in changes do
		table.insert(consumed, change.file)
	end
	local summary = readReleaseSummary()
	if summary then
		table.insert(consumed, summary.file)
	end
	removeUnreleasedChanges(consumed)
	for _, file in consumed do
		table.insert(changedFiles, file)
	end

	return changedFiles
end

return prepareReleaseFiles
