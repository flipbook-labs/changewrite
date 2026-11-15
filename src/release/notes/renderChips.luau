local notesTypes = require("@root/release/notes/types")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function lookUp(chips: notesTypes.ChipMarkup, key: string): string
	local markup = chips[key]
	assert(markup, `There's no chip for {key}. Run \`changewrite generate\` and commit the result`)
	return markup
end

-- The entry's kind chip, then a chip for each flag.
local function renderChips(entry: UnreleasedChange, chips: notesTypes.ChipMarkup): string
	local rendered: { string } = {}
	if entry.kind then
		table.insert(rendered, lookUp(chips, `kind/{entry.kind}`))
	end
	for _, flag in entry.flags do
		table.insert(rendered, lookUp(chips, `flag/{flag}`))
	end
	return table.concat(rendered, " ")
end

return renderChips
