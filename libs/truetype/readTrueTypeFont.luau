local types = require("./types")

type Font = types.Font
type Glyph = types.Glyph
type GlyphPoint = types.GlyphPoint

-- Flags in a simple glyph's flag array, from the TrueType `glyf` spec.
local ON_CURVE = 0x01
local X_SHORT = 0x02
local Y_SHORT = 0x04
local REPEAT = 0x08
local X_SAME_OR_POSITIVE = 0x10
local Y_SAME_OR_POSITIVE = 0x20

-- TrueType is big-endian, while `buffer` reads little-endian.
local function readU16(data: buffer, offset: number): number
	return bit32.bor(bit32.lshift(buffer.readu8(data, offset), 8), buffer.readu8(data, offset + 1))
end

local function readI16(data: buffer, offset: number): number
	local value = readU16(data, offset)
	return if value >= 0x8000 then value - 0x10000 else value
end

local function readU32(data: buffer, offset: number): number
	return readU16(data, offset) * 0x10000 + readU16(data, offset + 2)
end

local function readTables(data: buffer): { [string]: number }
	local tables: { [string]: number } = {}
	local count = readU16(data, 4)
	for index = 0, count - 1 do
		local record = 12 + index * 16
		tables[buffer.readstring(data, record, 4)] = readU32(data, record + 8)
	end
	return tables
end

-- Maps characters to glyph indices through the Windows Unicode BMP subtable,
-- which uses format 4.
local function readCharacterMap(data: buffer, cmapOffset: number): (number) -> number
	local subtableOffset: number? = nil
	local count = readU16(data, cmapOffset + 2)
	for index = 0, count - 1 do
		local record = cmapOffset + 4 + index * 8
		local platform = readU16(data, record)
		local encoding = readU16(data, record + 2)
		if platform == 3 and encoding == 1 then
			subtableOffset = cmapOffset + readU32(data, record + 4)
			break
		end
	end
	assert(subtableOffset, "Font has no Windows Unicode character map")
	assert(readU16(data, subtableOffset) == 4, "Font's character map is not format 4")

	local segmentCount = readU16(data, subtableOffset + 6) / 2
	local endCodes = subtableOffset + 14
	local startCodes = endCodes + segmentCount * 2 + 2
	local idDeltas = startCodes + segmentCount * 2
	local idRangeOffsets = idDeltas + segmentCount * 2

	return function(code: number): number
		for segment = 0, segmentCount - 1 do
			local endCode = readU16(data, endCodes + segment * 2)
			if code > endCode then
				continue
			end
			local startCode = readU16(data, startCodes + segment * 2)
			if code < startCode then
				return 0
			end

			local delta = readI16(data, idDeltas + segment * 2)
			local rangeOffsetPosition = idRangeOffsets + segment * 2
			local rangeOffset = readU16(data, rangeOffsetPosition)
			if rangeOffset == 0 then
				return (code + delta) % 0x10000
			end
			local glyphIndex = readU16(data, rangeOffsetPosition + rangeOffset + (code - startCode) * 2)
			if glyphIndex == 0 then
				return 0
			end
			return (glyphIndex + delta) % 0x10000
		end
		return 0
	end
end

local function readSimpleGlyph(data: buffer, offset: number, contourCount: number): { { GlyphPoint } }
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

-- Reads the outlines and advance widths of a static TrueType font. Composite
-- glyphs, such as accented letters built from parts, aren't supported, and
-- asking for one raises an error.
local function readTrueTypeFont(data: buffer): Font
	local tables = readTables(data)
	for _, required in { "head", "hhea", "hmtx", "maxp", "cmap", "loca", "glyf", "OS/2" } do
		assert(tables[required], `Font is missing its "{required}" table`)
	end

	local unitsPerEm = readU16(data, tables.head + 18)
	local isLongLocations = readI16(data, tables.head + 50) == 1
	local glyphCount = readU16(data, tables.maxp + 4)
	local horizontalMetricCount = readU16(data, tables.hhea + 34)
	local capHeight = readI16(data, tables["OS/2"] + 88)
	local getGlyphIndex = readCharacterMap(data, tables.cmap)

	local function getLocation(glyphIndex: number): number
		if isLongLocations then
			return readU32(data, tables.loca + glyphIndex * 4)
		end
		return readU16(data, tables.loca + glyphIndex * 2) * 2
	end

	local function getAdvanceWidth(glyphIndex: number): number
		local metricIndex = math.min(glyphIndex, horizontalMetricCount - 1)
		return readU16(data, tables.hmtx + metricIndex * 4)
	end

	local function getGlyph(character: string): Glyph
		local code = utf8.codepoint(character)
		local glyphIndex = getGlyphIndex(code)
		assert(glyphIndex ~= 0 and glyphIndex < glyphCount, `Font has no glyph for "{character}"`)

		local start = getLocation(glyphIndex)
		local finish = getLocation(glyphIndex + 1)
		if start == finish then
			return {
				advanceWidth = getAdvanceWidth(glyphIndex),
				contours = {},
			}
		end

		local offset = tables.glyf + start
		local contourCount = readI16(data, offset)
		assert(contourCount >= 0, `The glyph for "{character}" is a composite glyph, which isn't supported`)
		return {
			advanceWidth = getAdvanceWidth(glyphIndex),
			contours = readSimpleGlyph(data, offset, contourCount),
		}
	end

	return {
		unitsPerEm = unitsPerEm,
		capHeight = capHeight,
		getGlyph = getGlyph,
	}
end

return readTrueTypeFont
