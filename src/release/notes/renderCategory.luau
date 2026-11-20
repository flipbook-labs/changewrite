local notesTypes = require("@root/release/notes/types")
local renderEntryText = require("@root/release/notes/renderEntryText")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderCategory(
	category: string,
	entries: { UnreleasedChange },
	context: notesTypes.NotesContext,
	isCollapsed: boolean
): string
	local items: { string } = {}
	for _, entry in entries do
		-- A highlighted entry's summary and description are under Highlights, so
		-- here it is listed by title to keep the category scannable.
		table.insert(items, renderEntryText(entry, context, true))
	end
	local list = table.concat(items, "\n\n")

	if isCollapsed then
		return table.concat({
			"<details>",
			`<summary>{category} ({#entries})</summary>`,
			"",
			list,
			"",
			"</details>",
		}, "\n")
	end
	return `### {category}\n\n{list}`
end

return renderCategory
