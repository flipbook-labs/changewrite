local test = require("@std/test")

local getNextVersion = require("@root/release/getNextVersion")

test.suite("getNextVersion", function(suite)
	suite:case("major bumps the major and resets the minor and patch", function(assert)
		assert.eq(getNextVersion("1.2.3", "major"), "2.0.0")
	end)

	suite:case("minor bumps the minor and resets the patch", function(assert)
		assert.eq(getNextVersion("1.2.3", "minor"), "1.3.0")
	end)

	suite:case("patch increments only the patch", function(assert)
		assert.eq(getNextVersion("1.2.3", "patch"), "1.2.4")
	end)

	suite:case("minor from a zero patch", function(assert)
		assert.eq(getNextVersion("0.4.0", "minor"), "0.5.0")
	end)
end)
