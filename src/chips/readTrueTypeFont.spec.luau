local fs = require("@std/fs")
local test = require("@std/test")

local readTrueTypeFont = require("@root/chips/readTrueTypeFont")

local FONT_PATH = "assets/chips/font/SchibstedGrotesk-Bold.ttf"

test.suite("readTrueTypeFont", function(suite)
	local font = readTrueTypeFont(buffer.fromstring(fs.readFileToString(FONT_PATH)))

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

	suite:case("rejects a character the font doesn't cover", function(assert)
		assert.throws(function()
			font.getGlyph("漢")
		end)
	end)
end)
