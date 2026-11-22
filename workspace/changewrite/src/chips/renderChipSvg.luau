local vector = require("@workspace/vector")

local escapeXmlAttribute = require("@root/chips/escapeXmlAttribute")
local types = require("@root/chips/types")

type ChipLayers = types.ChipLayers
type ChipPalette = types.ChipPalette
type Paint = types.Paint
type Path = vector.Path

local function renderShape(path: Path, paint: Paint): string
	local opacity = if paint.opacity < 1 then ` fill-opacity="{vector.formatNumber(paint.opacity)}"` else ""
	return `<path d="{vector.pathToSvgData(path)}" fill="{paint.color}"{opacity}/>`
end

-- The label is drawn as shapes rather than text, because an SVG shown as an
-- image can't load web fonts.
local function renderChipSvg(layers: ChipLayers, palette: ChipPalette, label: string): string
	local name = escapeXmlAttribute(label)
	return table.concat({
		`<svg xmlns="http://www.w3.org/2000/svg" width="{layers.width}" height="{layers.height}" viewBox="0 0 {layers.width} {layers.height}" role="img" aria-label="{name}">`,
		renderShape(layers.rim, palette.rim),
		renderShape(layers.tint, palette.tint),
		renderShape(layers.dot, palette.dot),
		renderShape(layers.text, palette.text),
		"</svg>",
		"",
	}, "\n")
end

return renderChipSvg
