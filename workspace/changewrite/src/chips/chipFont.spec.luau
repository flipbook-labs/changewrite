local fs = require("@std/fs")
local path = require("@std/path")
local test = require("@std/test")

local base64 = require("@lpm/batteries@v1.0.1-nightly.20261115/base64")

local fontData = require("@root/chips/fontData")
local getChipFont = require("@root/chips/getChipFont")

-- The font sits in the `font` folder beside this spec. The path starts from
-- this file rather than the working folder, so the spec finds the font
-- whichever folder `lute test` runs from.
local SPEC_DIR = path.dirname(path.resolve(debug.info(1, "s")))
local FONT_PATH = path.join(SPEC_DIR, "font", "SchibstedGrotesk-Bold.ttf")

test.suite("chip font", function(suite)
	local font = getChipFont()

	suite:case("embeds the font file byte for byte", function(assert)
		-- Run `lute run embed-font` when this fails after replacing the font.
		local embedded = buffer.tostring(base64.decode(buffer.fromstring(fontData)))
		assert.eq(embedded == fs.readFileToString(FONT_PATH), true)
	end)

	suite:case("reads the font's em size and cap height", function(assert)
		-- Values read independently from the font's head and OS/2 tables.
		assert.eq(font.unitsPerEm, 2048)
		assert.eq(font.capHeight, 1440)
	end)

	suite:case("reads a letter's outline and advance width", function(assert)
		local glyph = font.getGlyph("O")

		-- An O is a ring: an outer contour and the counter inside it.
		assert.eq(#glyph.contours, 2)
		assert.eq(glyph.advanceWidth > 0, true)
	end)

	suite:case("gives a space an advance but no outline", function(assert)
		local glyph = font.getGlyph(" ")

		assert.eq(#glyph.contours, 0)
		assert.eq(glyph.advanceWidth > 0, true)
	end)

	suite:case("reads a letter the font builds from other glyphs", function(assert)
		-- The font draws "i" as a dotless i plus a dot.
		local glyph = font.getGlyph("i")

		assert.eq(#glyph.contours, 2)
	end)

	suite:case("rejects a character the font doesn't cover", function(assert)
		assert.throws(function()
			font.getGlyph("漢")
		end)
	end)
end)
