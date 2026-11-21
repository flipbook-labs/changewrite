local test = require("@std/test")

local planChips = require("./planChips")
local types = require("./types")

type ChipStyle = types.ChipStyle

local function style(text: string, color: string): ChipStyle
	return {
		group = "kind",
		name = "engine",
		text = text,
		colorMode = {
			light = { color = color },
			dark = { color = color },
		},
	}
end

test.suite("planChips", function(suite)
	suite:case("names each chip's files after its group and name", function(assert)
		local chip = planChips({ style("Engine", "#7c5cff") })[1]

		assert.eq(chip.key, "kind/engine")
		assert.eq(chip.files.light, "kind-engine-light.svg")
		assert.eq(chip.files.dark, "kind-engine-dark.svg")
		assert.eq(chip.files.fallback, "kind-engine-light.png")
	end)

	suite:case("keeps a chip's filenames when it's restyled", function(assert)
		local first = planChips({ style("Engine", "#7c5cff") })[1]
		local restyled = planChips({ style("Runtime", "#2da44e") })[1]

		assert.eq(restyled.files.light, first.files.light)
		assert.eq(restyled.files.fallback, first.files.fallback)
	end)
end)
