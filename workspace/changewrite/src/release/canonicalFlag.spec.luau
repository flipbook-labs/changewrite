local test = require("@std/test")

local canonicalFlag = require("@root/release/canonicalFlag")

test.suite("canonicalFlag", function(suite)
	suite:case("spells a known flag the current way in any case", function(assert)
		assert.eq(canonicalFlag("breaking"), "Breaking")
		assert.eq(canonicalFlag("SECURITY"), "Security")
		assert.eq(canonicalFlag("Deprecated"), "Deprecated")
	end)

	suite:case("keeps an unknown flag as written", function(assert)
		assert.eq(canonicalFlag("experimental"), "experimental")
	end)
end)
