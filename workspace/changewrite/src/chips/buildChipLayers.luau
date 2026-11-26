local truetype = require("@workspace/truetype")
local vector = require("@workspace/vector")

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
	local innerWidth = width - metrics.rimWidth * 2
	local innerHeight = metrics.height - metrics.rimWidth * 2

	local rim: Path = vector.pillPath(0, 0, width, metrics.height)
	for _, command in vector.pillPath(metrics.rimWidth, metrics.rimWidth, innerWidth, innerHeight, true) do
		table.insert(rim, command)
	end

	local dotY = (metrics.height - metrics.dotDiameter) / 2
	local labelX = metrics.paddingLeft + metrics.dotDiameter + metrics.dotGap
	local capHeight = font.capHeight * metrics.fontSize / font.unitsPerEm
	local baselineY = (metrics.height + capHeight) / 2

	local text: Path = {}
	for _, command in truetype.layoutText(font, label, labelX, baselineY, metrics.fontSize, metrics.letterSpacing) do
		table.insert(text, command)
	end

	return {
		width = width,
		height = metrics.height,
		rim = rim,
		tint = vector.pillPath(metrics.rimWidth, metrics.rimWidth, innerWidth, innerHeight),
		dot = vector.pillPath(metrics.paddingLeft, dotY, metrics.dotDiameter, metrics.dotDiameter),
		text = text,
	}
end

return buildChipLayers
