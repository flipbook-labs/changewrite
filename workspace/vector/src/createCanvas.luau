local rasterizePath = require("./rasterizePath")
local types = require("./types")

type Color = types.Color
type Path = types.Path

export type Canvas = {
	width: number,
	height: number,
	fillPath: (path: Path, color: Color) -> (),
	toRgba: () -> buffer,
}

-- A transparent RGBA canvas that paths are painted onto in order, each over the
-- last. Path coordinates are multiplied by `scale`, so the same path can be
-- drawn at any density.
local function createCanvas(width: number, height: number, scale: number): Canvas
	local count = width * height
	local red = table.create(count, 0)
	local green = table.create(count, 0)
	local blue = table.create(count, 0)
	local alpha = table.create(count, 0)

	local function fillPath(path: Path, color: Color)
		local coverage = rasterizePath(path, width, height, scale)
		for index = 1, count do
			local sourceAlpha = coverage[index] * color.a
			if sourceAlpha > 0 then
				local remaining = alpha[index] * (1 - sourceAlpha)
				local outAlpha = sourceAlpha + remaining
				red[index] = (color.r * sourceAlpha + red[index] * remaining) / outAlpha
				green[index] = (color.g * sourceAlpha + green[index] * remaining) / outAlpha
				blue[index] = (color.b * sourceAlpha + blue[index] * remaining) / outAlpha
				alpha[index] = outAlpha
			end
		end
	end

	-- Straight RGBA, one byte per channel, row by row.
	local function toRgba(): buffer
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
		return pixels
	end

	return {
		width = width,
		height = height,
		fillPath = fillPath,
		toRgba = toRgba,
	}
end

return createCanvas
