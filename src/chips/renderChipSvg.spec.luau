local test = require("@std/test")

local renderChipSvg = require("@root/chips/renderChipSvg")
local types = require("@root/chips/types")

type ChipPalette = types.ChipPalette

local PALETTE: ChipPalette = {
	tint = { color = "#ffffff", opacity = 1 },
	rim = { color = "#000000", opacity = 0.5 },
	dot = { color = "#ff0000", opacity = 1 },
	text = { color = "#0000ff", opacity = 1 },
}

test.suite("renderChipSvg", function(suite)
	suite:case("escapes the label in the accessible name", function(assert)
		local svg = renderChipSvg({
			width = 40,
			height = 18,
			rim = {},
			tint = {},
			dot = {},
			text = {},
		}, PALETTE, 'R&D "BETA"')

		assert.neq(svg:find('aria-label="R&amp;D &quot;BETA&quot;"', 1, true), nil)
	end)

	suite:case("writes opacity only for translucent paints", function(assert)
		local svg = renderChipSvg({
			width = 40,
			height = 18,
			rim = {},
			tint = {},
			dot = {},
			text = {},
		}, PALETTE, "NEW")

		assert.neq(svg:find('<path d="" fill="#000000" fill-opacity="0.5"/>', 1, true), nil)
		assert.neq(svg:find('<path d="" fill="#ffffff"/>', 1, true), nil)
	end)
end)
