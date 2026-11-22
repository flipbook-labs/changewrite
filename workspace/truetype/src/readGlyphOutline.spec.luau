local test = require("@std/test")

local readGlyphOutline = require("./readGlyphOutline")

-- Builds a big-endian `glyf` entry from 16-bit values and raw bytes.
local function glyphBytes(parts: { { kind: "i16" | "u8", value: number } }): buffer
	local size = 0
	for _, part in parts do
		size += if part.kind == "i16" then 2 else 1
	end
	local data = buffer.create(size)
	local cursor = 0
	for _, part in parts do
		if part.kind == "i16" then
			local value = part.value % 0x10000
			buffer.writeu8(data, cursor, bit32.rshift(value, 8))
			buffer.writeu8(data, cursor + 1, bit32.band(value, 0xFF))
			cursor += 2
		else
			buffer.writeu8(data, cursor, part.value)
			cursor += 1
		end
	end
	return data
end

local function i16(value: number): { kind: "i16" | "u8", value: number }
	return { kind = "i16", value = value }
end

local function u8(value: number): { kind: "i16" | "u8", value: number }
	return { kind = "u8", value = value }
end

test.suite("readGlyphOutline", function(suite)
	suite:case("reads a glyph that records zero contours as blank", function(assert)
		local data = glyphBytes({ i16(0), i16(0), i16(0), i16(0), i16(0) })

		assert.eq(#readGlyphOutline(data, 0), 0)
	end)

	suite:case("reads a simple glyph's points", function(assert)
		-- One contour of three on-curve points, (0, 0), (100, 0), and (50, 80),
		-- with every coordinate stored as a 16-bit delta.
		local data = glyphBytes({
			i16(1),
			i16(0),
			i16(0),
			i16(100),
			i16(80),
			i16(2),
			i16(0),
			u8(0x01),
			u8(0x01),
			u8(0x01),
			i16(0),
			i16(100),
			i16(-50),
			i16(0),
			i16(0),
			i16(80),
		})

		local contours = readGlyphOutline(data, 0)

		assert.eq(#contours, 1)
		local points = contours[1]
		assert.eq(#points, 3)
		assert.eq(points[2].x, 100)
		assert.eq(points[2].y, 0)
		assert.eq(points[3].x, 50)
		assert.eq(points[3].y, 80)
		assert.eq(points[3].isOnCurve, true)
	end)

	suite:case("places a composite glyph's parts", function(assert)
		-- Two components of glyph 7: one moved by byte offsets (10, -5), and one
		-- moved by word offsets (300, 0) and scaled by half.
		local data = glyphBytes({
			i16(-1),
			i16(0),
			i16(0),
			i16(0),
			i16(0),
			i16(0x0002 + 0x0020),
			i16(7),
			u8(10),
			u8(0xFB),
			i16(0x0001 + 0x0002 + 0x0008),
			i16(7),
			i16(300),
			i16(0),
			i16(0x2000),
		})
		local requested: { number } = {}
		local contours = readGlyphOutline(data, 0, function(glyphIndex: number)
			table.insert(requested, glyphIndex)
			return { { { x = 100, y = 40, isOnCurve = true } } }
		end)

		assert.eq(#contours, 2)
		assert.eq(requested[1], 7)
		assert.eq(contours[1][1].x, 110)
		assert.eq(contours[1][1].y, 35)
		assert.eq(contours[2][1].x, 350)
		assert.eq(contours[2][1].y, 20)
	end)

	suite:case("rejects a composite glyph that places parts by matching points", function(assert)
		local data = glyphBytes({ i16(-1), i16(0), i16(0), i16(0), i16(0), i16(0), i16(7), u8(0), u8(0) })

		assert.throws(function()
			readGlyphOutline(data, 0, function()
				return {}
			end)
		end)
	end)
end)
