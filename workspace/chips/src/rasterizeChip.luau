local png = require("@png")
local vector = require("@vector")

local types = require("./types")

type ChipLayers = types.ChipLayers
type ChipPalette = types.ChipPalette
type Color = vector.Color
type Image = png.Image
type Paint = types.Paint

local function toColor(paint: Paint): Color
	local r, g, b = vector.parseHexColor(paint.color)
	return {
		r = r,
		g = g,
		b = b,
		a = paint.opacity,
	}
end

-- Paints the chip's layers in the same order as the SVG, onto a transparent
-- image `scale` times the chip's size.
local function rasterizeChip(layers: ChipLayers, palette: ChipPalette, scale: number): Image
	local canvas = vector.createCanvas(layers.width * scale, layers.height * scale, scale)
	canvas.fillPath(layers.rim, toColor(palette.rim))
	canvas.fillPath(layers.tint, toColor(palette.tint))
	canvas.fillPath(layers.dot, toColor(palette.dot))
	canvas.fillPath(layers.text, toColor(palette.text))

	return {
		width = canvas.width,
		height = canvas.height,
		pixels = canvas.toRgba(),
	}
end

return rasterizeChip
