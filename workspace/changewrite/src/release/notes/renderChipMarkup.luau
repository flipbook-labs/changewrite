local chips = require("@chips")

local notesTypes = require("@root/release/notes/types")
local renderChip = require("@root/release/notes/renderChip")

type PlannedChip = chips.PlannedChip

-- Renders each chip, so the notes can look one up by key.
local function renderChipMarkup(planned: { PlannedChip }, assetsUrl: string): notesTypes.ChipMarkup
	local markup: notesTypes.ChipMarkup = {}
	for _, chip in planned do
		markup[chip.key] = renderChip(chip, assetsUrl)
	end
	return markup
end

return renderChipMarkup
