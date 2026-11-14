local parseHexColor = require("@root/chips/parseHexColor")
local rasterizePath = require("@root/chips/rasterizePath")
local types = require("@root/chips/types")

type ChipLayers = types.ChipLayers
type ChipPalette = types.ChipPalette
type Paint = types.Paint
type Path = types.Path

export type Image = {
	width: number,
	height: number,
	-- Straight (not premultiplied) RGBA, one byte per channel, row by row.
	pixels: buffer,
}

-- Paints the chip's layers in the same order as the SVG, onto a transparent
-- image `scale` times the chip's size.
local function rasterizeChip(layers: ChipLayers, palette: ChipPalette, scale: number): Image
	local width = layers.width * scale
	local height = layers.height * scale
	local count = width * height
	local red = table.create(count, 0)
	local green = table.create(count, 0)
	local blue = table.create(count, 0)
	local alpha = table.create(count, 0)

	local function paint(path: Path, fill: Paint)
		local r, g, b = parseHexColor(fill.color)
		local coverage = rasterizePath(path, width, height, scale)
		for index = 1, count do
			local sourceAlpha = coverage[index] * fill.opacity
			if sourceAlpha > 0 then
				local remaining = alpha[index] * (1 - sourceAlpha)
				local outAlpha = sourceAlpha + remaining
				red[index] = (r * sourceAlpha + red[index] * remaining) / outAlpha
				green[index] = (g * sourceAlpha + green[index] * remaining) / outAlpha
				blue[index] = (b * sourceAlpha + blue[index] * remaining) / outAlpha
				alpha[index] = outAlpha
			end
		end
	end

	paint(layers.rim, palette.rim)
	paint(layers.tint, palette.tint)
	paint(layers.dot, palette.dot)
	paint(layers.text, palette.text)

	local function toByte(value: number): number
		return math.clamp(math.floor(value * 255 + 0.5), 0, 255)
	end

	local pixels = buffer.create(count * 4)
	for index = 1, count do
		local offset = (index - 1) * 4
		buffer.writeu8(pixels, offset, toByte(red[index]))
		buffer.writeu8(pixels, offset + 1, toByte(green[index]))
		buffer.writeu8(pixels, offset + 2, toByte(blue[index]))
		buffer.writeu8(pixels, offset + 3, toByte(alpha[index]))
	end

	return {
		width = width,
		height = height,
		pixels = pixels,
	}
end

return rasterizeChip
