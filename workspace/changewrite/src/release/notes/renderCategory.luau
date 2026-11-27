local constants = require("@root/release/constants")
local excerptItems = require("@root/release/excerptItems")
local isFocused = require("@root/release/notes/isFocused")
local notesTypes = require("@root/release/notes/types")
local renderEntryText = require("@root/release/notes/renderEntryText")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderList(entries: { UnreleasedChange }, context: notesTypes.NotesContext): string?
	local items: { string } = {}
	local focused: { boolean } = {}
	for _, entry in entries do
		-- A highlighted entry's summary and body are under Highlights, so
		-- here it is listed by title to keep the category scannable.
		table.insert(items, renderEntryText(entry, context, true))
		table.insert(focused, isFocused(entry, context))
	end

	if context.focus then
		local excerpt = excerptItems(items, focused, constants.EXCERPT_NEIGHBORS)
		if excerpt == nil then
			return nil
		end
		items = excerpt
	end
	return table.concat(items, "\n\n")
end

--[[
	A collapsed category keeps its heading so it reads as part of the notes,
	but shows only its first `visibleCount` entries and folds the rest under a
	toggle. A category that isn't collapsed passes `math.huge`.

	In a changelog preview, a category with none of the focused entries renders
	nil. When the focused entries are all on one side of the toggle, the other
	side is cut down to an excerpt marker, and the toggle's label still counts
	every entry it folds.
]]
local function renderCategory(
	category: string,
	entries: { UnreleasedChange },
	context: notesTypes.NotesContext,
	visibleCount: number
): string?
	if #entries <= visibleCount then
		local list = renderList(entries, context)
		if list == nil then
			return nil
		end
		return `### {category}\n\n{list}`
	end

	local visibleList = if visibleCount > 0
		then renderList(table.move(entries, 1, visibleCount, 1, {}), context)
		else nil
	local hidden = table.move(entries, visibleCount + 1, #entries, 1, {})
	local hiddenList = renderList(hidden, context)
	if visibleList == nil and hiddenList == nil then
		return nil
	end

	local blocks = { `### {category}` }
	if visibleCount > 0 then
		table.insert(blocks, visibleList or constants.EXCERPT_CUT)
	end
	table.insert(
		blocks,
		table.concat({
			"<details>",
			if visibleCount > 0
				then `<summary>See {#hidden} more</summary>`
				else `<summary>See all {#hidden}</summary>`,
			"",
			hiddenList or constants.EXCERPT_CUT,
			"",
			"</details>",
		}, "\n")
	)
	return table.concat(blocks, "\n\n")
end

return renderCategory
