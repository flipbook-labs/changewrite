local notesTypes = require("@root/release/notes/types")
local renderEntryText = require("@root/release/notes/renderEntryText")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- A collapsed category shows this many entries before folding the rest away,
-- enough to give a sense of what changed without pushing the release notes
-- down the page.
local VISIBLE_COLLAPSED_ENTRIES = 5

local function renderList(entries: { UnreleasedChange }, context: notesTypes.NotesContext): string
	local items: { string } = {}
	for _, entry in entries do
		-- A highlighted entry's summary and body are under Highlights, so
		-- here it is listed by title to keep the category scannable.
		table.insert(items, renderEntryText(entry, context, true))
	end
	return table.concat(items, "\n\n")
end

-- A collapsed category keeps its heading so it reads as part of the notes,
-- but folds any entries past the first few under a toggle.
local function renderCategory(
	category: string,
	entries: { UnreleasedChange },
	context: notesTypes.NotesContext,
	isCollapsed: boolean
): string
	if not isCollapsed or #entries <= VISIBLE_COLLAPSED_ENTRIES then
		return `### {category}\n\n{renderList(entries, context)}`
	end

	local visible = table.move(entries, 1, VISIBLE_COLLAPSED_ENTRIES, 1, {})
	local hidden = table.move(entries, VISIBLE_COLLAPSED_ENTRIES + 1, #entries, 1, {})
	return table.concat({
		`### {category}`,
		"",
		renderList(visible, context),
		"",
		"<details>",
		`<summary>See {#hidden} more</summary>`,
		"",
		renderList(hidden, context),
		"",
		"</details>",
	}, "\n")
end

return renderCategory
