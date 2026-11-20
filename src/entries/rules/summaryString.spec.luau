local test = require("@std/test")

local runEntryRules = require("../runEntryRules")

local function lintSummary(value: string): { string }
	local messages = {}
	for _, violation in runEntryRules(`return \{\n\tsummary = {value},\n}\n`) do
		if violation.lintname == "changewrite_summary_string" then
			table.insert(messages, violation.message)
		end
	end
	return messages
end

test.suite("changewrite_summary_string", function(suite)
	suite:case("allows a double- or single-quoted string", function(assert)
		assert.eq(#lintSummary('"Fix a thing."'), 0)
		assert.eq(#lintSummary("'Fix a thing.'"), 0)
	end)

	suite:case("flags a block string", function(assert)
		local messages = lintSummary("[[Fix a thing.]]")
		assert.eq(#messages, 1)
		assert.strContains(messages[1], "not a block string")
	end)

	suite:case("flags an interpolated string, with or without expressions", function(assert)
		local plain = lintSummary("`Fix a thing.`")
		local interpolated = lintSummary("`Fix {thing}.`")
		assert.eq(#plain, 1)
		assert.eq(#interpolated, 1)
		assert.strContains(plain[1], "not an interpolated one")
		assert.strContains(interpolated[1], "not an interpolated one")
	end)

	suite:case("flags an escaped newline", function(assert)
		local messages = lintSummary('"Fix a thing.\\nAnd another."')
		assert.eq(#messages, 1)
		assert.strContains(messages[1], "on one line")
	end)

	suite:case("flags a value that isn't a string", function(assert)
		local messages = lintSummary("SUMMARY")
		assert.eq(#messages, 1)
		assert.strContains(messages[1], "as a quoted string")
	end)
end)
