local chips = require("@chips")
local test = require("@std/test")

local renderChip = require("@root/release/notes/renderChip")

local planChips = chips.planChips

local function chip(text: string): chips.PlannedChip
	return planChips({
		{
			group = "kind",
			name = "engine",
			text = text,
			colorMode = {
				light = { color = "#7c5cff" },
				dark = { color = "#7c5cff" },
			},
		},
	})[1]
end

test.suite("renderChip", function(suite)
	suite:case("swaps sources by color mode and falls back to the PNG", function(assert)
		local markup = renderChip(chip("Engine"), "https://example.com/assets")

		assert.eq(
			markup,
			'<picture><source media="(prefers-color-scheme: dark)" srcset="https://example.com/assets/kind-engine-dark.svg">'
				.. '<source media="(prefers-color-scheme: light)" srcset="https://example.com/assets/kind-engine-light.svg">'
				.. '<img src="https://example.com/assets/kind-engine-light.png" alt="Engine" height="18" align="texttop"></picture>'
		)
	end)

	suite:case("escapes the text in the alt attribute", function(assert)
		local markup = renderChip(chip('R&D "core"'), ".changes/assets")

		assert.neq(markup:find('alt="R&amp;D &quot;core&quot;"', 1, true), nil)
	end)
end)
