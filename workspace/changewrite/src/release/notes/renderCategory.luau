local notesTypes = require("@root/release/notes/types")
local renderEntryText = require("@root/release/notes/renderEntryText")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- A collapsed category shows this many entries before folding the rest away,
-- enough to give a sense of what changed without pushing the release notes
-- down the page.
local VISIBLE_COLLAPSED_ENTRIES = 5

local function renderList(entries: { UnreleasedChange }, context: notesTypes.NotesContext, isSmall: boolean): string
	local items: { string } = {}
	for _, entry in entries do
		-- A highlighted entry's summary and body are under Highlights, so
		-- here it is listed by title to keep the category scannable.
		table.insert(items, renderEntryText(entry, context, true, isSmall))
	end
	return table.concat(items, "\n\n")
end

-- A collapsed category keeps its heading so it reads as part of the notes,
-- but its entries are set in small text, and any past the first few are
-- folded under a toggle.
local function renderCategory(
	category: string,
	entries: { UnreleasedChange },
	context: notesTypes.NotesContext,
	isCollapsed: boolean
): string
	if not isCollapsed then
		return `### {category}\n\n{renderList(entries, context, false)}`
	end

	local visible = table.move(entries, 1, math.min(#entries, VISIBLE_COLLAPSED_ENTRIES), 1, {})
	local section = `### {category}\n\n{renderList(visible, context, true)}`
	if #entries > VISIBLE_COLLAPSED_ENTRIES then
		local hidden = table.move(entries, VISIBLE_COLLAPSED_ENTRIES + 1, #entries, 1, {})
		section ..= "\n\n" .. table.concat({
			"<details>",
			`<summary>See {#hidden} more</summary>`,
			"",
			renderList(hidden, context, true),
			"",
			"</details>",
		}, "\n")
	end
	return section
end

return renderCategory
