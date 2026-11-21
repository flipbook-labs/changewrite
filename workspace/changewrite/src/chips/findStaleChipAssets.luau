local chips = require("@chips")
local fs = require("@std/fs")
local path = require("@std/path")

local findStaleChips = require("@root/chips/findStaleChips")
local getAssetsDir = require("@root/chips/getAssetsDir")
local readChipStyles = require("@root/chips/readChipStyles")

local chipDrawing = chips.chipDrawing
local generateChips = chips.generateChips
local getChipFont = chips.getChipFont
local planChips = chips.planChips

-- Draws the chips changewrite.toml describes and returns a line for each one
-- whose files in the assets folder are missing or different. `generate --check`
-- and `check` print these.
local function findStaleChipAssets(): { string }
	local planned = planChips(readChipStyles())
	local specs = {}
	for _, chip in planned do
		table.insert(specs, chip.spec)
	end

	local drawn: { [string]: string } = {}
	for _, file in generateChips(getChipFont(), specs, chipDrawing.metrics, chipDrawing.pngScale) do
		drawn[file.name] = file.contents
	end

	local dir = getAssetsDir()
	return findStaleChips(planned, drawn, function(name: string): string?
		local file = path.join(dir, name)
		return if fs.exists(file) then fs.readFileToString(file) else nil
	end)
end

return findStaleChipAssets
