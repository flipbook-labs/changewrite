local truetype = require("@libs/truetype")
local vector = require("@libs/vector")

local types = require("@root/chips/types")

type ChipLayers = types.ChipLayers
type ChipMetrics = types.ChipMetrics
type Font = truetype.Font
type Path = vector.Path

-- Lays out one chip: a pill with a rim, a dot, then the label. The width is
-- rounded up to a whole pixel so the chip sits on the pixel grid wherever it's
-- shown, and the extra fraction goes to the right padding.
local function buildChipLayers(font: Font, label: string, metrics: ChipMetrics): ChipLayers
	local labelWidth = truetype.measureText(font, label, metrics.fontSize, metrics.letterSpacing)
	local width =
		math.ceil(metrics.paddingLeft + metrics.dotDiameter + metrics.dotGap + labelWidth + metrics.paddingRight)
	local height = metrics.height
	local inset = metrics.rimWidth

	local rim: Path = vector.pillPath(0, 0, width, height)
	for _, command in vector.pillPath(inset, inset, width - inset * 2, height - inset * 2, true) do
		table.insert(rim, command)
	end

	local dotY = (height - metrics.dotDiameter) / 2
	local labelX = metrics.paddingLeft + metrics.dotDiameter + metrics.dotGap
	local capHeight = font.capHeight * metrics.fontSize / font.unitsPerEm
	local baselineY = (height + capHeight) / 2

	local text: Path = {}
	for _, command in truetype.layoutText(font, label, labelX, baselineY, metrics.fontSize, metrics.letterSpacing) do
		table.insert(text, command)
	end

	return {
		width = width,
		height = height,
		rim = rim,
		tint = vector.pillPath(inset, inset, width - inset * 2, height - inset * 2),
		dot = vector.pillPath(metrics.paddingLeft, dotY, metrics.dotDiameter, metrics.dotDiameter),
		text = text,
	}
end

return buildChipLayers
