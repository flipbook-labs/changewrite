local test = require("@std/test")

local parseVersionComponent = require("@root/release/parseVersionComponent")

test.suite("parseVersionComponent", function(suite)
	suite:case("accepts major", function(assert)
		assert.eq(parseVersionComponent("major"), "major")
	end)

	suite:case("accepts minor", function(assert)
		assert.eq(parseVersionComponent("minor"), "minor")
	end)

	suite:case("accepts patch", function(assert)
		assert.eq(parseVersionComponent("patch"), "patch")
	end)

	suite:case("errors on an unknown component", function(assert)
		assert.throws(function()
			parseVersionComponent("nope")
		end)
	end)
end)
