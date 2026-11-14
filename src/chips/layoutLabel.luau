local glyphToPath = require("@root/chips/glyphToPath")
local types = require("@root/chips/types")

type Font = types.Font
type Path = types.Path

-- Places each glyph of the label along a baseline and joins their outlines
-- into one path.
local function layoutLabel(
	font: Font,
	label: string,
	originX: number,
	baselineY: number,
	fontSize: number,
	letterSpacing: number
): Path
	local scale = fontSize / font.unitsPerEm
	local path: Path = {}
	local cursor = originX
	for _, code in utf8.codes(label) do
		local glyph = font.getGlyph(utf8.char(code))
		for _, command in glyphToPath(glyph, cursor, baselineY, scale) do
			table.insert(path, command)
		end
		cursor += glyph.advanceWidth * scale + letterSpacing
	end
	return path
end

return layoutLabel
