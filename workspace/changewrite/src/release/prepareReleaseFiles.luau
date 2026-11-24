local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local findEntryOrigin = require("@root/release/notes/findEntryOrigin")
local findPullRequestTimes = require("@root/release/notes/findPullRequestTimes")
local getAssetsDir = require("@root/chips/getAssetsDir")
local getChipAssetsUrl = require("@root/release/notes/getChipAssetsUrl")
local getRepositoryUrl = require("@root/release/notes/getRepositoryUrl")
local planChips = require("@root/chips/planChips")
local prependSection = require("@root/release/prependSection")
local readCategories = require("@root/release/readCategories")
local readChipStyles = require("@root/chips/readChipStyles")
local readCollapsedCategories = require("@root/release/readCollapsedCategories")
local readCollapsedVisible = require("@root/release/readCollapsedVisible")
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
		local namedPrs: { number } = {}
		for _, change in changes do
			if change.pr then
				table.insert(namedPrs, change.pr)
			end
		end
		local prTimes = findPullRequestTimes(namedPrs)
		for _, change in changes do
			local origin = findEntryOrigin(change.file)
			local copy = table.clone(change)
			copy.pr = change.pr or origin.pr
			-- An entry that names its PR was usually added by a different one,
			-- such as a PR that backfills entries. It sorts by when its own PR
			-- merged, so it lands among the changes it came before. If that
			-- merge isn't in the history, it sorts by the commit that added it.
			local time = if change.pr then prTimes[change.pr] or origin.addedAt else origin.addedAt
			if time then
				addedAt[copy] = time
			end
			table.insert(resolved, copy)
		end
		resolved = sortByAddedAt(resolved, addedAt)
		local repositoryUrl = getRepositoryUrl()
		local assetsDir = getAssetsDir()
		-- Only chips whose files `changewrite generate` has written get markup.
		-- An entry that uses any other chip fails to render with a message
		-- naming that command, instead of linking an image that doesn't exist.
		-- Files that exist but are out of date are `check`'s job to catch.
		local generated: { planChips.PlannedChip } = {}
		for _, chip in planChips(readChipStyles()) do
			if fs.exists(path.join(assetsDir, chip.files.fallback)) then
				table.insert(generated, chip)
			end
		end
		local chips = renderChipMarkup(
			generated,
			getChipAssetsUrl(repositoryUrl, resolveBaseBranch() or "main", tostring(assetsDir))
		)
		section = renderRichChangelogSection(nextVersion, resolved, {
			categories = categories,
			collapsed = collapsed,
			collapsedVisible = readCollapsedVisible(),
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
