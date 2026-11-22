local test = require("@std/test")

local findStaleChips = require("@root/chips/findStaleChips")
local planChips = require("@root/chips/planChips")
local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle

local function style(name: string): ChipStyle
	return {
		group = "kind",
		name = name,
		text = name,
		colorMode = {
			light = { color = "#7c5cff" },
			dark = { color = "#7c5cff" },
		},
	}
end

-- Stands in for the drawn files: each file's contents are its own name.
local function draw(planned: { planChips.PlannedChip }): { [string]: string }
	local drawn: { [string]: string } = {}
	for _, chip in planned do
		for _, file in { chip.files.light, chip.files.dark, chip.files.fallback } do
			drawn[file] = file
		end
	end
	return drawn
end

test.suite("findStaleChips", function(suite)
	suite:case("passes when every file matches what would be drawn", function(assert)
		local planned = planChips({ style("engine") })
		local drawn = draw(planned)

		assert.eq(#findStaleChips(planned, drawn, function(name: string): string?
			return drawn[name]
		end), 0)
	end)

	suite:case("reports a chip whose files are missing", function(assert)
		local planned = planChips({ style("engine") })

		local stale = findStaleChips(planned, draw(planned), function(name: string): string?
			return if name:match("%.png$") then nil else name
		end)
		assert.eq(table.concat(stale, "\n"), "kind/engine is missing kind-engine-light.png")
	end)

	suite:case("reports a chip whose files differ once per chip", function(assert)
		local planned = planChips({ style("engine"), style("docs") })

		local stale = findStaleChips(planned, draw(planned), function(name: string): string?
			return if name:match("^kind%-engine") then "an earlier look" else name
		end)
		assert.eq(table.concat(stale, "\n"), "kind/engine changed in changewrite.toml")
	end)
end)
