local test = require("@std/test")

local runEntryRules = require("../runEntryRules")

local function lintSummary(summary: string, maxLength: number?): { string }
	local source = `return \{\n\tbump = "patch",\n\tsummary = "{summary}",\n}\n`
	local options = if maxLength then { max_length = maxLength } else {}
	local messages = {}
	for _, violation in runEntryRules(source, nil, { changewrite_summary_length = { options = options } }) do
		if violation.lintname == "changewrite_summary_length" then
			table.insert(messages, violation.message)
		end
	end
	return messages
end

test.suite("changewrite_summary_length", function(suite)
	suite:case("allows a summary of exactly 140 characters", function(assert)
		assert.eq(#lintSummary(string.rep("a", 140)), 0)
	end)

	suite:case("flags a summary over 140 characters", function(assert)
		local messages = lintSummary(string.rep("a", 141))
		assert.eq(#messages, 1)
		assert.strContains(messages[1], "141 characters, over the limit of 140")
	end)

	suite:case("counts characters rather than bytes", function(assert)
		assert.eq(#lintSummary(string.rep("é", 140)), 0)
	end)

	suite:case("reads the limit from the max_length option", function(assert)
		assert.eq(#lintSummary(string.rep("a", 141), 200), 0)
		assert.eq(#lintSummary(string.rep("a", 21), 20), 1)
	end)

	suite:case("reports the line of the summary", function(assert)
		local source = 'local entry = {\n\tbump = "patch",\n\tsummary = "'
			.. string.rep("a", 141)
			.. '",\n}\n\nreturn entry\n'
		local violations = runEntryRules(source)
		assert.eq(#violations, 1)
		assert.eq(violations[1].location.beginLine, 3)
	end)

	suite:case("ignores a file that doesn't return a table", function(assert)
		assert.eq(#runEntryRules(`local summary = "{string.rep("a", 141)}"\n\nreturn nil\n`), 0)
	end)
end)
