local test = require("@std/test")

local isPublishBranch = require("@root/release/isPublishBranch")

test.suite("isPublishBranch", function(suite)
	suite:case("matches the publish branch", function(assert)
		assert.eq(isPublishBranch("publish-next-version", "publish-next-version"), true)
	end)

	suite:case("matches the debug variant of the publish branch", function(assert)
		assert.eq(isPublishBranch("debug-publish-next-version", "publish-next-version"), true)
	end)

	suite:case("does not match a feature branch", function(assert)
		assert.eq(isPublishBranch("fix-release-permissions", "publish-next-version"), false)
	end)

	suite:case("does not match a branch that only contains the publish branch name", function(assert)
		assert.eq(isPublishBranch("publish-next-version-fix", "publish-next-version"), false)
	end)
end)
