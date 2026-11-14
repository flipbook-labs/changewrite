local types = require("@root/chips/types")

type Font = types.Font

-- The label's width in pixels: each glyph's advance, plus letter spacing
-- between glyphs but not after the last one.
local function measureLabel(font: Font, label: string, fontSize: number, letterSpacing: number): number
	local scale = fontSize / font.unitsPerEm
	local width = 0
	local count = 0
	for _, code in utf8.codes(label) do
		width += font.getGlyph(utf8.char(code)).advanceWidth * scale
		count += 1
	end
	return width + letterSpacing * math.max(count - 1, 0)
end

return measureLabel
