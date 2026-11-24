local notesTypes = require("@root/release/notes/types")
local renderEntryText = require("@root/release/notes/renderEntryText")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

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
-- but shows only its first `visibleCount` entries and folds the rest under a
-- toggle. A category that isn't collapsed passes `math.huge`.
local function renderCategory(
	category: string,
	entries: { UnreleasedChange },
	context: notesTypes.NotesContext,
	visibleCount: number
): string
	if #entries <= visibleCount then
		return `### {category}\n\n{renderList(entries, context)}`
	end

	local blocks = { `### {category}` }
	if visibleCount > 0 then
		table.insert(blocks, renderList(table.move(entries, 1, visibleCount, 1, {}), context))
	end
	local hidden = table.move(entries, visibleCount + 1, #entries, 1, {})
	table.insert(
		blocks,
		table.concat({
			"<details>",
			if visibleCount > 0
				then `<summary>See {#hidden} more</summary>`
				else `<summary>See all {#hidden}</summary>`,
			"",
			renderList(hidden, context),
			"",
			"</details>",
		}, "\n")
	)
	return table.concat(blocks, "\n\n")
end

return renderCategory
