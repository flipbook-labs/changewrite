local base64 = require("@batteries/base64")
local truetype = require("@libs/truetype")

local fontData = require("@root/chips/fontData")

type Font = truetype.Font

local font: Font? = nil

-- Decoded on first use, since only `generate` draws chips.
local function getChipFont(): Font
	if font == nil then
		font = truetype.readTrueTypeFont(base64.decode(buffer.fromstring(fontData)))
	end
	return font :: Font
end

return getChipFont
