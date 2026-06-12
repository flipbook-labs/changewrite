local test = require("@std/test")

local parseVersion = require("@root/release/parseVersion")

test.suite("parseVersion", function(suite)
	suite:case("splits a semver string into components", function(assert)
		local major, minor, patch = parseVersion("10.20.30")
		assert.eq(major, 10)
		assert.eq(minor, 20)
		assert.eq(patch, 30)
	end)
end)
