local test = require("@std/test")

local resolveNextVersion = require("@root/release/resolveNextVersion")

test.suite("resolveNextVersion", function(suite)
	suite:case("bumps a tagged version by the pending change", function(assert)
		assert.eq(resolveNextVersion("1.2.3", true, "minor"), "1.3.0")
	end)

	suite:case("keeps an untagged version that is still being prepared", function(assert)
		assert.eq(resolveNextVersion("1.2.3", false, "patch"), "1.2.3")
	end)

	suite:case("keeps a tagged version when no bump is pending", function(assert)
		assert.eq(resolveNextVersion("1.2.3", true, nil), "1.2.3")
	end)

	suite:case("bootstraps the first release to 0.1.0", function(assert)
		assert.eq(resolveNextVersion("0.0.0", false, "patch"), "0.1.0")
		assert.eq(resolveNextVersion("0.0.0", false, "minor"), "0.1.0")
	end)

	suite:case("bootstraps straight to 1.0.0 for a major change", function(assert)
		assert.eq(resolveNextVersion("0.0.0", false, "major"), "1.0.0")
	end)

	suite:case("bumps away from the placeholder even when it was tagged", function(assert)
		assert.eq(resolveNextVersion("0.0.0", true, "patch"), "0.1.0")
	end)
end)
