local renderEntryText = require("@root/release/notes/renderEntryText")
local renderNumberedList = require("@root/release/notes/renderNumberedList")
local sortByKind = require("@root/release/notes/sortByKind")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderCategory(
	category: string,
	entries: { UnreleasedChange },
	repositoryUrl: string?,
	isCollapsed: boolean
): string
	local items: { string } = {}
	for _, entry in sortByKind(entries) do
		-- A highlighted entry's full body is under Highlights, so here it is
		-- listed by title to keep the category scannable.
		table.insert(items, renderEntryText(entry, repositoryUrl, true))
	end
	local list = renderNumberedList(items)

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
