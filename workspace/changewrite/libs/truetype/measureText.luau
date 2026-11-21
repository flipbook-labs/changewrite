local types = require("./types")

type Font = types.Font

-- The text's width in pixels: each glyph's advance, plus letter spacing
-- between glyphs but not after the last one.
local function measureText(font: Font, text: string, fontSize: number, letterSpacing: number): number
	local scale = fontSize / font.unitsPerEm
	local width = 0
	local count = 0
	for _, code in utf8.codes(text) do
		width += font.getGlyph(utf8.char(code)).advanceWidth * scale
		count += 1
	end
	return width + letterSpacing * math.max(count - 1, 0)
end

return measureText
