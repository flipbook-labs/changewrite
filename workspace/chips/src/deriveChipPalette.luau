local types = require("./types")

type ChipPalette = types.ChipPalette
type ColorModeName = types.ColorModeName
type ColorModeStyle = types.ColorModeStyle

-- Neutral text for each color mode, close to GitHub's own body text, so a chip
-- reads like the line it sits in.
local DEFAULT_TEXT_COLOR: { [ColorModeName]: string } = {
	light = "#1f2328",
	dark = "#d1d9e0",
}

-- The fill is a faint wash of black or white rather than a fixed color, so the
-- pill blends into whatever surface it's on.
local FILL: { [ColorModeName]: string } = {
	light = "#000000",
	dark = "#ffffff",
}

-- A neutral pill whose border and dot carry the chip's color.
local function deriveChipPalette(mode: ColorModeName, style: ColorModeStyle): ChipPalette
	return {
		tint = { color = FILL[mode], opacity = 0.04 },
		rim = { color = style.color, opacity = 0.55 },
		dot = { color = style.color, opacity = 1 },
		text = { color = style.textColor or DEFAULT_TEXT_COLOR[mode], opacity = 1 },
	}
end

return deriveChipPalette
