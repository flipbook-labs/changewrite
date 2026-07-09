local test = require("@std/test")

local pickHighestVersion = require("@root/release/pickHighestVersion")

test.suite("pickHighestVersion", function(suite)
	suite:case("returns the sole version", function(assert)
		assert.eq(pickHighestVersion({ "0.3.0" }), "0.3.0")
	end)

	suite:case("picks the highest across differing majors", function(assert)
		assert.eq(pickHighestVersion({ "0.9.0", "1.0.0", "0.2.1" }), "1.0.0")
	end)

	suite:case("compares minor then patch", function(assert)
		assert.eq(pickHighestVersion({ "1.2.9", "1.3.0" }), "1.3.0")
		assert.eq(pickHighestVersion({ "1.2.3", "1.2.10" }), "1.2.10")
	end)
end)
