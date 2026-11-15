local chipLock = require("@root/chips/chipLock")
local notesTypes = require("@root/release/notes/types")
local renderChip = require("@root/release/notes/renderChip")

-- Renders every chip in the lockfile, so the notes can look each one up by key.
local function renderChipMarkup(lock: chipLock.ChipLock, assetsUrl: string): notesTypes.ChipMarkup
	local markup: notesTypes.ChipMarkup = {}
	for key, chip in lock do
		markup[key] = renderChip(chip, assetsUrl)
	end
	return markup
end

return renderChipMarkup
