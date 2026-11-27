local fs = require("@std/fs")
local path = require("@std/path")

local findEntryOrigin = require("@root/release/notes/findEntryOrigin")
local findPullRequestTimes = require("@root/release/notes/findPullRequestTimes")
local getAssetsDir = require("@root/chips/getAssetsDir")
local getChipAssetsUrl = require("@root/release/notes/getChipAssetsUrl")
local getRepositoryUrl = require("@root/release/notes/getRepositoryUrl")
local planChips = require("@root/chips/planChips")
local readCategories = require("@root/release/readCategories")
local readChipStyles = require("@root/chips/readChipStyles")
local readCollapsedCategories = require("@root/release/readCollapsedCategories")
local readCollapsedVisible = require("@root/release/readCollapsedVisible")
local readReleaseSummary = require("@root/release/readReleaseSummary")
local renderChangelogSection = require("@root/release/renderChangelogSection")
local renderChipMarkup = require("@root/release/notes/renderChipMarkup")
local renderRichChangelogSection = require("@root/release/notes/renderRichChangelogSection")
local resolveBaseBranch = require("@root/release/resolveBaseBranch")
local sortByAddedAt = require("@root/release/notes/sortByAddedAt")
local types = require("@root/release/types")
local usesRichNotes = require("@root/release/notes/usesRichNotes")

type UnreleasedChange = types.UnreleasedChange

export type ReleaseSectionOptions = {
	-- Renders a changelog preview of these entry files instead of the whole
	-- section.
	focus: types.Focus?,
	--[[
		The pull request a changelog preview is for. A focused entry that
		doesn't name its pull request, and wasn't added by a squash merge that
		names one, links to this one, as it will once that pull request merges.
	]]
	pullRequest: number?,
}

-- The CHANGELOG.md section for a release of `changes`, read with the repo's
-- changelog settings.
local function renderReleaseSection(
	nextVersion: string,
	changes: { UnreleasedChange },
	options: ReleaseSectionOptions?
): string
	local focus = if options then options.focus else nil
	local pullRequest = if options then options.pullRequest else nil
	local categories = readCategories()
	local collapsed = readCollapsedCategories()
	local summary = readReleaseSummary()

	if not usesRichNotes(changes, summary, collapsed) then
		return renderChangelogSection(nextVersion, changes, categories, focus)
	end

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
		local isFocused = focus ~= nil and focus[tostring(change.file)] == true
		copy.pr = change.pr or origin.pr or (if isFocused then pullRequest else nil)
		--[[
			An entry that names its PR was usually added by a different one,
			such as a PR that backfills entries. It sorts by when its own PR
			merged, so it lands among the changes it came before. If that
			merge isn't in the history, it sorts by the commit that added it.
		]]
		local time = if change.pr then prTimes[change.pr] or origin.addedAt else origin.addedAt
		if time then
			addedAt[copy] = time
		end
		table.insert(resolved, copy)
	end
	resolved = sortByAddedAt(resolved, addedAt)
	local repositoryUrl = getRepositoryUrl()
	local assetsDir = getAssetsDir()
	--[[
		Only chips whose files `changewrite generate` has written get markup.
		An entry that uses any other chip fails to render with a message
		naming that command, instead of linking an image that doesn't exist.
		Files that exist but are out of date are `check`'s job to catch.
	]]
	local generated: { planChips.PlannedChip } = {}
	for _, chip in planChips(readChipStyles()) do
		if fs.exists(path.join(assetsDir, chip.files.fallback)) then
			table.insert(generated, chip)
		end
	end
	local chips =
		renderChipMarkup(generated, getChipAssetsUrl(repositoryUrl, resolveBaseBranch() or "main", tostring(assetsDir)))
	return renderRichChangelogSection(nextVersion, resolved, {
		categories = categories,
		collapsed = collapsed,
		collapsedVisible = readCollapsedVisible(),
		summary = summary,
		repositoryUrl = repositoryUrl,
		chips = chips,
		focus = focus,
	})
end

return renderReleaseSection
