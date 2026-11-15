local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local findEntryOrigin = require("@root/release/notes/findEntryOrigin")
local getAssetsDir = require("@root/chips/getAssetsDir")
local getChipAssetsUrl = require("@root/release/notes/getChipAssetsUrl")
local getRepositoryUrl = require("@root/release/notes/getRepositoryUrl")
local prependSection = require("@root/release/prependSection")
local readCategories = require("@root/release/readCategories")
local readChipLock = require("@root/chips/readChipLock")
local readCollapsedCategories = require("@root/release/readCollapsedCategories")
local readReleaseSummary = require("@root/release/readReleaseSummary")
local removeUnreleasedChanges = require("@root/release/removeUnreleasedChanges")
local renderChangelogSection = require("@root/release/renderChangelogSection")
local renderChipMarkup = require("@root/release/notes/renderChipMarkup")
local renderRichChangelogSection = require("@root/release/notes/renderRichChangelogSection")
local resolveBaseBranch = require("@root/release/resolveBaseBranch")
local sortByAddedAt = require("@root/release/notes/sortByAddedAt")
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
		local addedAt: { [UnreleasedChange]: number } = {}
		for _, change in changes do
			local origin = findEntryOrigin(change.file)
			local copy = table.clone(change)
			copy.pr = change.pr or origin.pr
			if origin.addedAt then
				addedAt[copy] = origin.addedAt
			end
			table.insert(resolved, copy)
		end
		resolved = sortByAddedAt(resolved, addedAt)
		local repositoryUrl = getRepositoryUrl()
		local lock = readChipLock()
		local chips = if lock
			then renderChipMarkup(
				lock,
				getChipAssetsUrl(repositoryUrl, resolveBaseBranch() or "main", tostring(getAssetsDir()))
			)
			else nil
		section = renderRichChangelogSection(nextVersion, resolved, {
			categories = categories,
			collapsed = collapsed,
			summary = summary,
			repositoryUrl = repositoryUrl,
			chips = chips,
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
