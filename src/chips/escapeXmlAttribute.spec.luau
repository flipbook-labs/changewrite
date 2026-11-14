local test = require("@std/test")

local escapeXmlAttribute = require("@root/chips/escapeXmlAttribute")

test.suite("escapeXmlAttribute", function(suite)
	suite:case("escapes every character that's special in an attribute", function(assert)
		assert.eq(escapeXmlAttribute([[a&b<c>d"e'f]]), "a&amp;b&lt;c&gt;d&quot;e&apos;f")
	end)

	suite:case("leaves plain text alone", function(assert)
		assert.eq(escapeXmlAttribute("IMPROVED"), "IMPROVED")
	end)
end)
