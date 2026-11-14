local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local findEntryPullRequest = require("@root/release/notes/findEntryPullRequest")
local getRepositoryUrl = require("@root/release/notes/getRepositoryUrl")
local prependSection = require("@root/release/prependSection")
local readCategories = require("@root/release/readCategories")
local readCollapsedCategories = require("@root/release/readCollapsedCategories")
local readReleaseSummary = require("@root/release/readReleaseSummary")
local removeUnreleasedChanges = require("@root/release/removeUnreleasedChanges")
local renderChangelogSection = require("@root/release/renderChangelogSection")
local renderRichChangelogSection = require("@root/release/notes/renderRichChangelogSection")
local types = require("@root/release/types")
local usesRichNotes = require("@root/release/notes/usesRichNotes")
local writeVersion = require("@root/release/writeVersion")

type UnreleasedChange = types.UnreleasedChange

local DEFAULT_HEADER = "# Changelog\n\nAll notable changes to this project will be documented in this file."

local function prepareReleaseFiles(nextVersion: string, changes: { UnreleasedChange }): { path.Path }
	local changedFiles = writeVersion(nextVersion)

	if #changes == 0 then
		return changedFiles
	end

	local categories = readCategories()
	local collapsed = readCollapsedCategories()
	local summary = readReleaseSummary()

	local section: string
	if usesRichNotes(changes, summary, collapsed) then
		local resolved: { UnreleasedChange } = {}
		for _, change in changes do
			local copy = table.clone(change)
			copy.pr = change.pr or findEntryPullRequest(change.file)
			table.insert(resolved, copy)
		end
		section = renderRichChangelogSection(nextVersion, resolved, {
			categories = categories,
			collapsed = collapsed,
			summary = summary,
			repositoryUrl = getRepositoryUrl(),
		})
	else
		section = renderChangelogSection(nextVersion, changes, categories)
	end
	local existing = if fs.exists(constants.CHANGELOG_FILE)
		then fs.readFileToString(constants.CHANGELOG_FILE)
		else DEFAULT_HEADER
	fs.writeStringToFile(constants.CHANGELOG_FILE, prependSection(existing, section))
	table.insert(changedFiles, path.parse(constants.CHANGELOG_FILE))

	local consumed: { path.Path } = {}
	for _, change in changes do
		table.insert(consumed, change.file)
	end
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
