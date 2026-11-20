local test = require("@std/test")

local runEntryRules = require("../runEntryRules")

local function lintDescription(value: string): { string }
	local messages = {}
	local source = `return \{\n\tsummary = "Fix a thing.",\n\tdescription = {value},\n}\n`
	for _, violation in runEntryRules(source) do
		if violation.lintname == "changewrite_description_string" then
			table.insert(messages, violation.message)
		end
	end
	return messages
end

test.suite("changewrite_description_string", function(suite)
	suite:case("allows a block string at any level", function(assert)
		assert.eq(#lintDescription("[[\nMore detail.\n]]"), 0)
		assert.eq(#lintDescription("[==[\nMore ]] detail.\n]==]"), 0)
	end)

	suite:case("flags a quoted description", function(assert)
		local messages = lintDescription('"More detail."')
		assert.eq(#messages, 1)
		assert.strContains(messages[1], "block string")
	end)

	suite:case("allows an entry without a description", function(assert)
		local violations = runEntryRules('return {\n\tsummary = "Fix a thing.",\n}\n')
		assert.eq(#violations, 0)
	end)
end)
