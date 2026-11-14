local test = require("@std/test")

local parseReleaseSummary = require("@root/release/parseReleaseSummary")

test.suite("parseReleaseSummary", function(suite)
	suite:case("reads a name from frontmatter and the TL;DR from the body", function(assert)
		local summary = parseReleaseSummary("---\nname: Out in the open\n---\n\nFlipbook now runs outside Studio.\n")

		assert.eq(summary.name, "Out in the open")
		assert.eq(summary.tldr, "Flipbook now runs outside Studio.")
	end)

	suite:case("treats a file without frontmatter as just the TL;DR", function(assert)
		local summary = parseReleaseSummary("Flipbook now runs outside Studio.\n")

		assert.eq(summary.name, nil)
		assert.eq(summary.tldr, "Flipbook now runs outside Studio.")
	end)

	suite:case("rejects a summary with no TL;DR", function(assert)
		assert.throws(function()
			parseReleaseSummary("---\nname: Empty\n---\n")
		end)
	end)
end)
