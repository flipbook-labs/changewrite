local test = require("@std/test")

local renderChip = require("@root/release/notes/renderChip")

test.suite("renderChip", function(suite)
	suite:case("swaps sources by color mode and falls back to the PNG", function(assert)
		local markup = renderChip({
			text = "Engine",
			hash = "1a2b3c4d",
			files = {
				light = "kind-engine-1a2b3c4d-light.svg",
				dark = "kind-engine-1a2b3c4d-dark.svg",
				fallback = "kind-engine-1a2b3c4d-light.png",
			},
		}, "https://example.com/assets")

		assert.eq(
			markup,
			'<picture><source media="(prefers-color-scheme: dark)" srcset="https://example.com/assets/kind-engine-1a2b3c4d-dark.svg">'
				.. '<source media="(prefers-color-scheme: light)" srcset="https://example.com/assets/kind-engine-1a2b3c4d-light.svg">'
				.. '<img src="https://example.com/assets/kind-engine-1a2b3c4d-light.png" alt="Engine" height="18" align="texttop"></picture>'
		)
	end)

	suite:case("escapes the text in the alt attribute", function(assert)
		local markup = renderChip({
			text = 'R&D "core"',
			hash = "00000000",
			files = { light = "a.svg", dark = "b.svg", fallback = "c.png" },
		}, ".changes/assets")

		assert.neq(markup:find('alt="R&amp;D &quot;core&quot;"', 1, true), nil)
	end)
end)
