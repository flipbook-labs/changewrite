local test = require("@std/test")

local chipLock = require("@root/chips/chipLock")
local planChips = require("@root/chips/planChips")
local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle

local function style(group: "kind" | "flag", name: string, text: string): ChipStyle
	return {
		group = group,
		name = name,
		text = text,
		colorMode = {
			light = { color = "#7c5cff" },
			dark = { color = "#7c5cff" },
		},
	}
end

test.suite("chipLock", function(suite)
	suite:case("reads back what it writes", function(assert)
		local planned = planChips({ style("kind", "engine", 'The "core"'), style("flag", "breaking", "Breaking") })
		local lock = chipLock.parse(chipLock.serialize(planned))

		assert.eq(lock["kind/engine"].text, 'The "core"')
		assert.eq(lock["kind/engine"].hash, planned[1].hash)
		assert.eq(lock["kind/engine"].files.fallback, planned[1].files.fallback)
		assert.eq(lock["flag/breaking"].files.dark, planned[2].files.dark)
	end)

	suite:case("writes keys in sorted order whatever order chips arrive in", function(assert)
		local forward = chipLock.serialize(planChips({ style("kind", "a", "A"), style("kind", "b", "B") }))
		local backward = chipLock.serialize(planChips({ style("kind", "b", "B"), style("kind", "a", "A") }))

		assert.eq(forward, backward)
		assert.eq((forward:find('"kind/a"', 1, true) :: number) < (forward:find('"kind/b"', 1, true) :: number), true)
	end)

	suite:case("rejects an entry missing a file", function(assert)
		assert.throws(function()
			chipLock.parse('{"chips": {"kind/a": {"text": "A", "hash": "00000000"}}}')
		end)
	end)
end)
