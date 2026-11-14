local ChangeKind = require("@root/release/ChangeKind")
local demoteHeadings = require("@root/release/notes/demoteHeadings")
local renderActionBanner = require("@root/release/notes/renderActionBanner")
local renderBreakingChanges = require("@root/release/notes/renderBreakingChanges")
local renderCategory = require("@root/release/notes/renderCategory")
local renderHighlights = require("@root/release/notes/renderHighlights")
local renderReleaseName = require("@root/release/notes/renderReleaseName")
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
		copy.body = demoteHeadings(entry.body)
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
		if entry.kind == ChangeKind.Breaking then
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

	add(if summary then renderReleaseName(summary) else nil)
	add(renderActionBanner(entries))
	add(renderReleaseTldr(summary, entries))
	add(renderStatsLine(entries, options.collapsed))
	add(renderBreakingChanges(entries, options.repositoryUrl))
	add(renderHighlights(entries, options.repositoryUrl))

	for _, category in categories do
		if byCategory[category] and not table.find(options.collapsed, category) then
			add(renderCategory(category, byCategory[category], options.repositoryUrl, false))
		end
	end
	for _, category in categories do
		if byCategory[category] and table.find(options.collapsed, category) then
			add(renderCategory(category, byCategory[category], options.repositoryUrl, true))
		end
	end

	local section = `## v{plain}`
	if #blocks > 0 then
		section ..= "\n\n" .. table.concat(blocks, "\n\n")
	end
	return section
end

return renderRichChangelogSection
