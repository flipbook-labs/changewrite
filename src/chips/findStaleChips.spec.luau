local test = require("@std/test")

local chipLock = require("@root/chips/chipLock")
local findStaleChips = require("@root/chips/findStaleChips")
local planChips = require("@root/chips/planChips")
local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle

local function style(name: string, color: string): ChipStyle
	return {
		group = "kind",
		name = name,
		text = name,
		colorMode = {
			light = { color = color },
			dark = { color = color },
		},
	}
end

local function always(_name: string): boolean
	return true
end

test.suite("findStaleChips", function(suite)
	suite:case("passes when the lockfile and files match the config", function(assert)
		local planned = planChips({ style("engine", "#7c5cff") })
		local lock = chipLock.parse(chipLock.serialize(planned))

		assert.eq(#findStaleChips(planned, lock, always), 0)
	end)

	suite:case("reports a missing lockfile", function(assert)
		local stale = findStaleChips(planChips({ style("engine", "#7c5cff") }), nil, always)

		assert.eq(stale[1], "The chip lockfile is missing")
	end)

	suite:case("reports added, restyled, and removed chips", function(assert)
		local lock = chipLock.parse(chipLock.serialize(planChips({
			style("engine", "#7c5cff"),
			style("legacy", "#7c5cff"),
		})))
		local planned = planChips({ style("engine", "#2da44e"), style("docs", "#7c5cff") })

		local stale = findStaleChips(planned, lock, always)
		assert.eq(
			table.concat(stale, "\n"),
			table.concat({
				"kind/engine changed in changewrite.toml",
				"kind/docs has no chip yet",
				"kind/legacy is no longer in changewrite.toml",
			}, "\n")
		)
	end)

	suite:case("reports a chip whose files are missing", function(assert)
		local planned = planChips({ style("engine", "#7c5cff") })
		local lock = chipLock.parse(chipLock.serialize(planned))

		local stale = findStaleChips(planned, lock, function(name: string): boolean
			return not name:match("%.png$")
		end)
		assert.eq(stale[1], `kind/engine is missing {planned[1].files.fallback}`)
	end)
end)
