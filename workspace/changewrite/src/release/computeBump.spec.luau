local test = require("@std/test")

local computeBump = require("@root/release/computeBump")

test.suite("computeBump", function(suite)
	suite:case("returns the only component when there is just one", function(assert)
		assert.eq(computeBump({ "patch" }), "patch")
	end)

	suite:case("major beats minor and patch", function(assert)
		assert.eq(computeBump({ "patch", "major", "minor" }), "major")
	end)

	suite:case("minor beats patch", function(assert)
		assert.eq(computeBump({ "patch", "minor", "patch" }), "minor")
	end)

	suite:case("patch when every entry is a patch", function(assert)
		assert.eq(computeBump({ "patch", "patch" }), "patch")
	end)

	suite:case("returns nil for an empty set", function(assert)
		assert.eq(computeBump({}), nil)
	end)
end)
