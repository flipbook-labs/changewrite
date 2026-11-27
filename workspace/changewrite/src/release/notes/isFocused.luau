local notesTypes = require("@root/release/notes/types")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function isFocused(entry: UnreleasedChange, context: notesTypes.NotesContext): boolean
	return context.focus ~= nil and context.focus[tostring(entry.file)] == true
end

return isFocused
