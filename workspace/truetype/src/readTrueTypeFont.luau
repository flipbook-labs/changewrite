local readCapHeight = require("./readCapHeight")
local readGlyphOutline = require("./readGlyphOutline")
local readI16 = require("./readI16")
local readU16 = require("./readU16")
local readU32 = require("./readU32")
local types = require("./types")

type Font = types.Font
type Glyph = types.Glyph
type GlyphPoint = types.GlyphPoint

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
local function readCharacterMap(data: buffer, cmapOffset: number): (codepoint: number) -> number
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

-- Reads the outlines and advance widths of a static TrueType font.
local function readTrueTypeFont(data: buffer): Font
	local tables = readTables(data)
	for _, required in
		{
			"head",
			"hhea",
			"hmtx",
			"maxp",
			"cmap",
			"loca",
			"glyf",
			"OS/2",
		}
	do
		assert(tables[required], `Font is missing its "{required}" table`)
	end

	local unitsPerEm = readU16(data, tables.head + 18)
	local isLongLocations = readI16(data, tables.head + 50) == 1
	local glyphCount = readU16(data, tables.maxp + 4)
	local horizontalMetricCount = readU16(data, tables.hhea + 34)
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

	-- Where a character's outline starts in the `glyf` table, or nil when its
	-- glyph has no outline at all, as a space usually doesn't.
	local function findGlyph(character: string): (number, number?)
		local code = utf8.codepoint(character)
		local glyphIndex = getGlyphIndex(code)
		assert(glyphIndex ~= 0 and glyphIndex < glyphCount, `Font has no glyph for "{character}"`)

		local start = getLocation(glyphIndex)
		if start == getLocation(glyphIndex + 1) then
			return glyphIndex, nil
		end
		return glyphIndex, tables.glyf + start
	end

	-- Composite glyphs can nest, so this stops at a depth no real font needs,
	-- in case a broken font refers back to a glyph it's part of.
	local MAX_COMPONENT_DEPTH = 8

	local function readOutline(_glyphIndex: number, offset: number, depth: number): { { GlyphPoint } }
		assert(depth <= MAX_COMPONENT_DEPTH, "Composite glyph nests too deeply")
		return readGlyphOutline(data, offset, function(componentIndex: number): { { GlyphPoint } }
			assert(componentIndex < glyphCount, `Composite glyph refers to missing glyph {componentIndex}`)
			local start = getLocation(componentIndex)
			if start == getLocation(componentIndex + 1) then
				return {}
			end
			return readOutline(componentIndex, tables.glyf + start, depth + 1)
		end)
	end

	local function getGlyph(character: string): Glyph
		local glyphIndex, offset = findGlyph(character)
		local contours: { { GlyphPoint } } = {}
		if offset then
			local isOk, result = pcall(readOutline, glyphIndex, offset, 0)
			assert(isOk, `Could not read the glyph for "{character}": {result}`)
			contours = result
		end
		return {
			advanceWidth = getAdvanceWidth(glyphIndex),
			contours = contours,
		}
	end

	-- Fonts with an older OS/2 table don't record a cap height, so it's taken
	-- from the top of the capital H instead.
	local capHeight = readCapHeight(data, tables["OS/2"], function(): number
		local _, offset = findGlyph("H")
		assert(offset, "Font's H has no outline to measure a cap height from")
		return readI16(data, offset + 8)
	end)

	return {
		unitsPerEm = unitsPerEm,
		capHeight = capHeight,
		getGlyph = getGlyph,
	}
end

return readTrueTypeFont
