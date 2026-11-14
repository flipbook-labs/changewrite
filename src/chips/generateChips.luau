local buildChipLayers = require("@root/chips/buildChipLayers")
local encodePng = require("@root/chips/encodePng")
local rasterizeChip = require("@root/chips/rasterizeChip")
local renderChipSvg = require("@root/chips/renderChipSvg")
local types = require("@root/chips/types")

type ChipMetrics = types.ChipMetrics
type ChipSpec = types.ChipSpec
type Font = types.Font

export type ChipFile = {
	name: string,
	contents: string,
}

-- Produces every file for a set of chips: a light and a dark SVG for each, and
-- a light PNG for places that don't show SVG, such as notification emails.
local function generateChips(font: Font, chips: { ChipSpec }, metrics: ChipMetrics, pngScale: number): { ChipFile }
	local files: { ChipFile } = {}
	for _, chip in chips do
		local layers = buildChipLayers(font, chip.label, metrics)
		table.insert(files, {
			name = `{chip.name}-light.svg`,
			contents = renderChipSvg(layers, chip.light, chip.label),
		})
		table.insert(files, {
			name = `{chip.name}-dark.svg`,
			contents = renderChipSvg(layers, chip.dark, chip.label),
		})
		table.insert(files, {
			name = `{chip.name}-light.png`,
			contents = encodePng(rasterizeChip(layers, chip.light, pngScale)),
		})
	end
	return files
end

return generateChips
