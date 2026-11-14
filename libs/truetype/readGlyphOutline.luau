local readI16 = require("./readI16")
local readU16 = require("./readU16")
local types = require("./types")

type GlyphPoint = types.GlyphPoint

-- Flags in a simple glyph's flag array, from the TrueType `glyf` spec.
local ON_CURVE = 0x01
local X_SHORT = 0x02
local Y_SHORT = 0x04
local REPEAT = 0x08
local X_SAME_OR_POSITIVE = 0x10
local Y_SAME_OR_POSITIVE = 0x20

-- Reads the contours of the glyph whose `glyf` entry starts at `offset`. A
-- glyph may record zero contours to stay blank. Composite glyphs, built from
-- other glyphs, aren't supported.
local function readGlyphOutline(data: buffer, offset: number): { { GlyphPoint } }
	local contourCount = readI16(data, offset)
	assert(contourCount >= 0, "Composite glyphs aren't supported")
	if contourCount == 0 then
		return {}
	end

	local endPoints: { number } = {}
	for index = 0, contourCount - 1 do
		table.insert(endPoints, readU16(data, offset + 10 + index * 2))
	end
	local pointCount = endPoints[#endPoints] + 1

	local instructionLength = readU16(data, offset + 10 + contourCount * 2)
	local cursor = offset + 12 + contourCount * 2 + instructionLength

	local flags: { number } = {}
	while #flags < pointCount do
		local flag = buffer.readu8(data, cursor)
		cursor += 1
		table.insert(flags, flag)
		if bit32.band(flag, REPEAT) ~= 0 then
			local repeats = buffer.readu8(data, cursor)
			cursor += 1
			for _ = 1, repeats do
				table.insert(flags, flag)
			end
		end
	end

	local function readCoordinates(shortFlag: number, sameFlag: number): { number }
		local values: { number } = {}
		local value = 0
		for _, flag in flags do
			if bit32.band(flag, shortFlag) ~= 0 then
				local delta = buffer.readu8(data, cursor)
				cursor += 1
				value += if bit32.band(flag, sameFlag) ~= 0 then delta else -delta
			elseif bit32.band(flag, sameFlag) == 0 then
				value += readI16(data, cursor)
				cursor += 2
			end
			table.insert(values, value)
		end
		return values
	end

	local xs = readCoordinates(X_SHORT, X_SAME_OR_POSITIVE)
	local ys = readCoordinates(Y_SHORT, Y_SAME_OR_POSITIVE)

	local contours: { { GlyphPoint } } = {}
	local first = 1
	for _, endPoint in endPoints do
		local contour: { GlyphPoint } = {}
		for index = first, endPoint + 1 do
			table.insert(contour, {
				x = xs[index],
				y = ys[index],
				isOnCurve = bit32.band(flags[index], ON_CURVE) ~= 0,
			})
		end
		table.insert(contours, contour)
		first = endPoint + 2
	end
	return contours
end

return readGlyphOutline
