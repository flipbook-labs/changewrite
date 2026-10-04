local test = require("@std/test")

local parsePublishBranch = require("@root/release/parsePublishBranch")

test.suite("parsePublishBranch", function(suite)
	suite:case("reads the configured publish branch", function(assert)
		assert.eq(parsePublishBranch({ release = { branch = "release-next" } }), "release-next")
	end)

	suite:case("defaults to publish-next-version without a release table", function(assert)
		assert.eq(parsePublishBranch({ version = { current = "1.2.3" } }), "publish-next-version")
	end)

	suite:case("defaults to publish-next-version when the release table omits branch", function(assert)
		assert.eq(parsePublishBranch({ release = {} }), "publish-next-version")
	end)

	suite:case("rejects an empty branch", function(assert)
		assert.throws(function()
			parsePublishBranch({ release = { branch = "" } })
		end)
	end)

	suite:case("rejects a non-string branch", function(assert)
		assert.throws(function()
			parsePublishBranch({ release = { branch = 1 } })
		end)
	end)
end)
