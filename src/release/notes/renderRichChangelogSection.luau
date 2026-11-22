local demoteHeadings = require("@root/release/notes/demoteHeadings")
local isBreaking = require("@root/release/notes/isBreaking")
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
	summary: ReleaseSummary?,
	repositoryUrl: string?,
	chips: notesTypes.ChipMarkup?,
}

-- Lays the section out so what a reader has to act on comes before what is
-- only informational: banner, TL;DR, breaking changes, highlights, then each
-- category, with collapsed categories last.
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

	local blocks: { string } = {}
	local function add(block: string?)
		if block then
			table.insert(blocks, block)
		end
	end

	local context: notesTypes.NotesContext = {
		repositoryUrl = options.repositoryUrl,
		chips = options.chips or {},
	}

	add(renderActionBanner(entries))
	add(renderReleaseTldr(summary, entries))
	add(renderStatsLine(entries, categories))
	add(renderBreakingChanges(entries, context))
	add(renderHighlights(entries, context))

	for _, category in categories do
		if byCategory[category] and not table.find(options.collapsed, category) then
			add(renderCategory(category, byCategory[category], context, false))
		end
	end
	for _, category in categories do
		if byCategory[category] and table.find(options.collapsed, category) then
			add(renderCategory(category, byCategory[category], context, true))
		end
	end

	local section = `## v{plain}`
	if #blocks > 0 then
		section ..= "\n\n" .. table.concat(blocks, "\n\n")
	end
	return section
end

return renderRichChangelogSection
