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

-- Flags on each component of a composite glyph.
local ARG_1_AND_2_ARE_WORDS = 0x0001
local ARGS_ARE_XY_VALUES = 0x0002
local WE_HAVE_A_SCALE = 0x0008
local MORE_COMPONENTS = 0x0020
local WE_HAVE_AN_X_AND_Y_SCALE = 0x0040
local WE_HAVE_A_TWO_BY_TWO = 0x0080

-- Reads one of a composite's F2Dot14 scale values: a signed 2.14 fixed-point
-- number.
local function readF2Dot14(data: buffer, cursor: number): number
	return readI16(data, cursor) / 16384
end

-- A composite glyph, such as an "i" built from a dotless i and a dot, lists
-- other glyphs to draw, each moved and optionally scaled. A part can instead be
-- placed by matching one of its points to a point already drawn, which isn't
-- supported and raises an error.
local function readCompositeOutline(
	data: buffer,
	offset: number,
	readComponent: (glyphIndex: number) -> { { GlyphPoint } }
): { { GlyphPoint } }
	local contours: { { GlyphPoint } } = {}
	local cursor = offset + 10
	local flags: number
	repeat
		flags = readU16(data, cursor)
		local glyphIndex = readU16(data, cursor + 2)
		cursor += 4

		assert(
			bit32.band(flags, ARGS_ARE_XY_VALUES) ~= 0,
			"Composite glyphs that place parts by matching points aren't supported"
		)
		local dx: number = 0
		local dy: number = 0
		if bit32.band(flags, ARG_1_AND_2_ARE_WORDS) ~= 0 then
			dx = readI16(data, cursor)
			dy = readI16(data, cursor + 2)
			cursor += 4
		else
			dx = buffer.readi8(data, cursor)
			dy = buffer.readi8(data, cursor + 1)
			cursor += 2
		end

		-- The component's transform, as the matrix [a c; b d].
		local a: number = 1
		local b: number = 0
		local c: number = 0
		local d: number = 1
		if bit32.band(flags, WE_HAVE_A_SCALE) ~= 0 then
			a = readF2Dot14(data, cursor)
			d = a
			cursor += 2
		elseif bit32.band(flags, WE_HAVE_AN_X_AND_Y_SCALE) ~= 0 then
			a = readF2Dot14(data, cursor)
			d = readF2Dot14(data, cursor + 2)
			cursor += 4
		elseif bit32.band(flags, WE_HAVE_A_TWO_BY_TWO) ~= 0 then
			a = readF2Dot14(data, cursor)
			b = readF2Dot14(data, cursor + 2)
			c = readF2Dot14(data, cursor + 4)
			d = readF2Dot14(data, cursor + 6)
			cursor += 8
		end

		for _, contour in readComponent(glyphIndex) do
			local moved: { GlyphPoint } = {}
			for _, point in contour do
				table.insert(moved, {
					x = a * point.x + c * point.y + dx,
					y = b * point.x + d * point.y + dy,
					isOnCurve = point.isOnCurve,
				})
			end
			table.insert(contours, moved)
		end
	until bit32.band(flags, MORE_COMPONENTS) == 0
	return contours
end

-- Reads the contours of the glyph whose `glyf` entry starts at `offset`. A
-- glyph may record zero contours to stay blank. A composite glyph's parts are
-- read through `readComponent`, which takes a glyph index.
local function readGlyphOutline(
	data: buffer,
	offset: number,
	readComponent: ((glyphIndex: number) -> { { GlyphPoint } })?
): { { GlyphPoint } }
	local contourCount = readI16(data, offset)
	if contourCount < 0 then
		assert(readComponent, "Reading a composite glyph needs a way to read its parts")
		return readCompositeOutline(data, offset, readComponent)
	end
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
