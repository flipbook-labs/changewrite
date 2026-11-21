local test = require("@std/test")

local findSummaryProblems = require("@root/entries/findSummaryProblems")

test.suite("findSummaryProblems", function(suite)
	suite:case("accepts a summary at the limit", function(assert)
		assert.eq(#findSummaryProblems(string.rep("a", 140), 140), 0)
	end)

	suite:case("reports a summary one character over the limit", function(assert)
		local problems = findSummaryProblems(string.rep("a", 141), 140)

		assert.eq(#problems, 1)
		assert.strContains(problems[1], "The summary is 141 characters, over the limit of 140")
	end)

	suite:case("measures in characters rather than bytes", function(assert)
		-- Each "é" is two bytes, so this is 140 characters and 280 bytes.
		assert.eq(#findSummaryProblems(string.rep("é", 140), 140), 0)
	end)

	suite:case("uses the limit it's given", function(assert)
		assert.eq(#findSummaryProblems(string.rep("a", 150), 200), 0)
		assert.eq(#findSummaryProblems(string.rep("a", 150), 120), 1)
	end)

	suite:case("reports a summary that spans lines", function(assert)
		local problems = findSummaryProblems("Fix a thing.\nAnd another.", 140)

		assert.eq(#problems, 1)
		assert.strContains(problems[1], "Keep the summary on one line")
	end)

	suite:case("reports both problems at once", function(assert)
		assert.eq(#findSummaryProblems(`{string.rep("a", 141)}\nMore.`, 140), 2)
	end)
end)
