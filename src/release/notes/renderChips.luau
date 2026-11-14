local renderChip = require("@root/release/notes/renderChip")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderChips(entry: UnreleasedChange): string
	local chips: { string } = {}
	if entry.kind then
		table.insert(chips, renderChip(entry.kind))
	end
	for _, flag in entry.flags do
		table.insert(chips, renderChip(flag))
	end
	return table.concat(chips, " ")
end

return renderChips
