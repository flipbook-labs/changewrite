local layoutLabel = require("@root/chips/layoutLabel")
local measureLabel = require("@root/chips/measureLabel")
local pillPath = require("@root/chips/pillPath")
local types = require("@root/chips/types")

type ChipLayers = types.ChipLayers
type ChipMetrics = types.ChipMetrics
type Font = types.Font
type Path = types.Path

-- Lays out one chip: a pill with a rim, a dot, then the label. The width is
-- rounded up to a whole pixel so the chip sits on the pixel grid wherever it's
-- shown, and the extra fraction goes to the right padding.
local function buildChipLayers(font: Font, label: string, metrics: ChipMetrics): ChipLayers
	local labelWidth = measureLabel(font, label, metrics.fontSize, metrics.letterSpacing)
	local width =
		math.ceil(metrics.paddingLeft + metrics.dotDiameter + metrics.dotGap + labelWidth + metrics.paddingRight)
	local height = metrics.height
	local inset = metrics.rimWidth

	local rim: Path = pillPath(0, 0, width, height)
	for _, command in pillPath(inset, inset, width - inset * 2, height - inset * 2, true) do
		table.insert(rim, command)
	end

	local dotY = (height - metrics.dotDiameter) / 2
	local labelX = metrics.paddingLeft + metrics.dotDiameter + metrics.dotGap
	local capHeight = font.capHeight * metrics.fontSize / font.unitsPerEm
	local baselineY = (height + capHeight) / 2

	return {
		width = width,
		height = height,
		rim = rim,
		tint = pillPath(inset, inset, width - inset * 2, height - inset * 2),
		dot = pillPath(metrics.paddingLeft, dotY, metrics.dotDiameter, metrics.dotDiameter),
		text = layoutLabel(font, label, labelX, baselineY, metrics.fontSize, metrics.letterSpacing),
	}
end

return buildChipLayers
