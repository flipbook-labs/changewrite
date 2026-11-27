local ChangeFlag = require("@root/release/ChangeFlag")
local demoteHeadings = require("@root/release/notes/demoteHeadings")
local excerptItems = require("@root/release/excerptItems")
local isBreaking = require("@root/release/notes/isBreaking")
local isFocused = require("@root/release/notes/isFocused")
local notesTypes = require("@root/release/notes/types")
local renderActionBanner = require("@root/release/notes/renderActionBanner")
local renderBreakingChanges = require("@root/release/notes/renderBreakingChanges")
local renderCategory = require("@root/release/notes/renderCategory")
local renderHighlights = require("@root/release/notes/renderHighlights")
local renderReleaseTldr = require("@root/release/notes/renderReleaseTldr")
local renderStatsLine = require("@root/release/notes/renderStatsLine")
local types = require("@root/release/types")

type ReleaseSummary = types.ReleaseSummary
type UnreleasedChange = types.UnreleasedChange

export type RichSectionOptions = {
	categories: { string }?,
	collapsed: { string },
	-- How many entries each collapsed category shows before its toggle. All of
	-- them show when this is nil.
	collapsedVisible: number?,
	summary: ReleaseSummary?,
	repositoryUrl: string?,
	chips: notesTypes.ChipMarkup?,
	-- Renders a changelog preview of these entry files instead of the whole
	-- section. See `NotesContext.focus`.
	focus: types.Focus?,
}

-- In a changelog preview, the banner shows when one of the focused entries
-- calls for it.
local function isBannerFocused(entries: { UnreleasedChange }, context: notesTypes.NotesContext): boolean
	for _, entry in entries do
		if isFocused(entry, context) and (isBreaking(entry) or table.find(entry.flags, ChangeFlag.Security)) then
			return true
		end
	end
	return false
end

-- In a changelog preview, the TL;DR shows when it's built from highlight
-- titles and one of them is a focused entry's.
local function isTldrFocused(
	summary: ReleaseSummary?,
	entries: { UnreleasedChange },
	context: notesTypes.NotesContext
): boolean
	if summary then
		return false
	end
	for _, entry in entries do
		if isFocused(entry, context) and entry.highlight then
			return true
		end
	end
	return false
end

--[[
	Lays the section out so what a reader has to act on comes before what is
	only informational: banner, TL;DR, breaking changes, highlights, then each
	category, with collapsed categories last.

	A changelog preview keeps the same layout but shows only the parts its
	focused entries appear in or change, and replaces each run of parts it
	leaves out with one excerpt marker. The stats line always shows, since
	every entry changes its counts.
]]
local function renderRichChangelogSection(
	version: string,
	entries: { UnreleasedChange },
	options: RichSectionOptions
): string
	local plain = version:gsub("^v", "")

	local demotedEntries: { UnreleasedChange } = {}
	for _, entry in entries do
		local copy = table.clone(entry)
		copy.summary = demoteHeadings(entry.summary)
		copy.body = if entry.body then demoteHeadings(entry.body) else nil
		table.insert(demotedEntries, copy)
	end
	entries = demotedEntries

	local summary = options.summary
	if summary then
		summary = table.clone(summary)
		summary.tldr = demoteHeadings(summary.tldr)
	end

	local byCategory: { [string]: { UnreleasedChange } } = {}
	local seenCategories: { string } = {}
	for _, entry in entries do
		if isBreaking(entry) then
			continue
		end
		if byCategory[entry.category] == nil then
			byCategory[entry.category] = {}
			table.insert(seenCategories, entry.category)
		end
		table.insert(byCategory[entry.category], entry)
	end

	local categories: { string } = seenCategories
	if options.categories then
		categories = options.categories
	else
		table.sort(categories)
	end

	local context: notesTypes.NotesContext = {
		repositoryUrl = options.repositoryUrl,
		chips = options.chips or {},
	}
	local focusContext: notesTypes.NotesContext = table.clone(context)
	focusContext.focus = options.focus

	-- Each part of the section as the full release renders it, and whether a
	-- changelog preview shows it. A part the release doesn't have is skipped.
	local parts: { string } = {}
	local focusedParts: { boolean } = {}
	local function add(part: string?, focusedPart: string?)
		if part then
			table.insert(parts, focusedPart or part)
			table.insert(focusedParts, focusedPart ~= nil)
		end
	end

	local banner = renderActionBanner(entries)
	add(banner, if isBannerFocused(entries, focusContext) then banner else nil)
	local tldr = renderReleaseTldr(summary, entries)
	add(tldr, if isTldrFocused(summary, entries, focusContext) then tldr else nil)
	local stats = renderStatsLine(entries, categories)
	add(stats, stats)
	add(renderBreakingChanges(entries, context), renderBreakingChanges(entries, focusContext))
	add(renderHighlights(entries, context), renderHighlights(entries, focusContext))

	local function addCategory(category: string, visibleCount: number)
		add(
			renderCategory(category, byCategory[category], context, visibleCount),
			renderCategory(category, byCategory[category], focusContext, visibleCount)
		)
	end
	for _, category in categories do
		if byCategory[category] and not table.find(options.collapsed, category) then
			addCategory(category, math.huge)
		end
	end
	for _, category in categories do
		if byCategory[category] and table.find(options.collapsed, category) then
			addCategory(category, options.collapsedVisible or math.huge)
		end
	end

	local blocks = parts
	if options.focus then
		blocks = excerptItems(parts, focusedParts, 0) or {}
	end

	local section = `## v{plain}`
	if #blocks > 0 then
		section ..= "\n\n" .. table.concat(blocks, "\n\n")
	end
	return section
end

return renderRichChangelogSection
