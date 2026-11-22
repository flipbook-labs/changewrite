local path = require("@std/path")
local test = require("@std/test")

local types = require("@root/release/types")
local usesRichNotes = require("@root/release/notes/usesRichNotes")

type UnreleasedChange = types.UnreleasedChange

local function plainEntry(): UnreleasedChange
	return {
		bump = "patch",
		category = "Changes",
		summary = "Fix a thing.",
		flags = {},
		file = path.parse("fix.md"),
	}
end

test.suite("usesRichNotes", function(suite)
	suite:case("stays off for entries that use none of the new fields", function(assert)
		assert.eq(usesRichNotes({ plainEntry() }, nil, {}), false)
	end)

	suite:case("turns on when any entry sets a release-notes field", function(assert)
		local withKind = plainEntry()
		withKind.kind = "engine"
		local withFlag = plainEntry()
		withFlag.flags = { "Security" }
		local withHighlight = plainEntry()
		withHighlight.highlight = "A headline"
		local withPr = plainEntry()
		withPr.pr = 4

		assert.eq(usesRichNotes({ plainEntry(), withKind }, nil, {}), true)
		assert.eq(usesRichNotes({ withFlag }, nil, {}), true)
		assert.eq(usesRichNotes({ withHighlight }, nil, {}), true)
		assert.eq(usesRichNotes({ withPr }, nil, {}), true)
	end)

	suite:case("turns on for a release summary or collapsed categories", function(assert)
		local summary: types.ReleaseSummary = {
			file = path.parse("release.md"),
			tldr = "A summary.",
		}

		assert.eq(usesRichNotes({ plainEntry() }, summary, {}), true)
		assert.eq(usesRichNotes({ plainEntry() }, nil, { "Internal" }), true)
	end)
end)
