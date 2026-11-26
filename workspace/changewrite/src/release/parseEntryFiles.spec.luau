local path = require("@std/path")
local test = require("@std/test")

local parseEntryFiles = require("@root/release/parseEntryFiles")

local VALID = [[
return {
	bump = "patch",
	summary = "Fix a thing.",
}
]]

local function entryFile(name: string, source: string): parseEntryFiles.EntryFile
	return {
		file = path.parse(`.changes/{name}`),
		source = source,
	}
end

test.suite("parseEntryFiles", function(suite)
	suite:case("reports every invalid entry and still parses the valid ones", function(assert)
		local result = parseEntryFiles({
			entryFile("a.luau", "return {}"),
			entryFile("b.luau", VALID),
			entryFile("c.luau", 'return { bump = "huge", summary = "Too big." }'),
		})

		assert.eq(#result.changes, 1)
		assert.eq(tostring(result.changes[1].file), ".changes/b.luau")
		assert.eq(#result.problems, 2)
		assert.eq(tostring(result.problems[1].file), ".changes/a.luau")
		assert.eq(tostring(result.problems[2].file), ".changes/c.luau")
	end)

	suite:case("drops Changewrite's own file and line from each problem", function(assert)
		local result = parseEntryFiles({ entryFile("a.luau", "return {}") })

		assert.eq(result.problems[1].problem, "Unreleased change has no summary")
	end)

	suite:case("keeps the entry's own line number in a syntax error", function(assert)
		local result = parseEntryFiles({ entryFile("a.luau", "return {\n\tbump = ,\n}") })

		assert.strContains(result.problems[1].problem, "Unreleased change is not valid Luau")
		assert.strContains(result.problems[1].problem, ":2:")
	end)

	suite:case("sorts changes and problems by file name", function(assert)
		local result = parseEntryFiles({
			entryFile("d.luau", VALID),
			entryFile("c.luau", "return {}"),
			entryFile("b.luau", VALID),
			entryFile("a.luau", "return {}"),
		})

		assert.eq(tostring(result.changes[1].file), ".changes/b.luau")
		assert.eq(tostring(result.changes[2].file), ".changes/d.luau")
		assert.eq(tostring(result.problems[1].file), ".changes/a.luau")
		assert.eq(tostring(result.problems[2].file), ".changes/c.luau")
	end)
end)
