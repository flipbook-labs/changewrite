local test = require("@std/test")

local parseReleaseSummary = require("@root/release/parseReleaseSummary")

test.suite("parseReleaseSummary", function(suite)
	suite:case("reads the whole file as the TL;DR", function(assert)
		local summary = parseReleaseSummary("Flipbook now runs outside Studio.\n")

		assert.eq(summary.tldr, "Flipbook now runs outside Studio.")
	end)

	suite:case("rejects an empty summary", function(assert)
		assert.throws(function()
			parseReleaseSummary("\n\n")
		end)
	end)
end)
