local notesTypes = require("@root/release/notes/types")
local planChips = require("@root/chips/planChips")
local renderChip = require("@root/release/notes/renderChip")

-- Renders each chip, so the notes can look one up by key.
local function renderChipMarkup(chips: { planChips.PlannedChip }, assetsUrl: string): notesTypes.ChipMarkup
	local markup: notesTypes.ChipMarkup = {}
	for _, chip in chips do
		markup[chip.key] = renderChip(chip, assetsUrl)
	end
	return markup
end

return renderChipMarkup
