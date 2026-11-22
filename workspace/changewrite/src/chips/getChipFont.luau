local base64 = require("@lpm/batteries@v1.0.1-nightly.20261115/base64")
local truetype = require("@workspace/truetype")

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
