local test = require("@std/test")

local planChips = require("@root/chips/planChips")
local types = require("@root/chips/types")

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
	suite:case("names each chip's files after its key and hash", function(assert)
		local chip = planChips({ style("Engine", "#7c5cff") })[1]

		assert.eq(chip.key, "kind/engine")
		assert.eq(#chip.hash, 8)
		assert.eq(chip.files.light, `kind-engine-{chip.hash}-light.svg`)
		assert.eq(chip.files.dark, `kind-engine-{chip.hash}-dark.svg`)
		assert.eq(chip.files.fallback, `kind-engine-{chip.hash}-light.png`)
	end)

	suite:case("keeps the hash for an unchanged chip and changes it on a restyle", function(assert)
		local first = planChips({ style("Engine", "#7c5cff") })[1]
		local again = planChips({ style("Engine", "#7c5cff") })[1]
		local recolored = planChips({ style("Engine", "#2da44e") })[1]
		local renamed = planChips({ style("Runtime", "#7c5cff") })[1]

		assert.eq(again.hash, first.hash)
		assert.neq(recolored.hash, first.hash)
		assert.neq(renamed.hash, first.hash)
	end)
end)
