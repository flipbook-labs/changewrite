local glyphToPath = require("./glyphToPath")
local types = require("./types")

type Font = types.Font
type Path = types.Path

-- Places each glyph of the text along a baseline and joins their outlines
-- into one path.
local function layoutText(
	font: Font,
	text: string,
	originX: number,
	baselineY: number,
	fontSize: number,
	letterSpacing: number
): Path
	local scale = fontSize / font.unitsPerEm
	local path: Path = {}
	local cursor = originX
	for _, code in utf8.codes(text) do
		local glyph = font.getGlyph(utf8.char(code))
		for _, command in glyphToPath(glyph, cursor, baselineY, scale) do
			table.insert(path, command)
		end
		cursor += glyph.advanceWidth * scale + letterSpacing
	end
	return path
end

return layoutText
