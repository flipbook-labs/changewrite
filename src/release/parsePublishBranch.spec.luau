local test = require("@std/test")

local parsePublishBranch = require("@root/release/parsePublishBranch")

test.suite("parsePublishBranch", function(suite)
	suite:case("reads the configured publish branch", function(assert)
		local text = [[
[release]
branch = "release-next"
]]

		assert.eq(parsePublishBranch(text), "release-next")
	end)

	suite:case("defaults to publish-next-version without a release table", function(assert)
		local text = [[
[version]
current = "1.2.3"
]]

		assert.eq(parsePublishBranch(text), "publish-next-version")
	end)

	suite:case("defaults to publish-next-version when the release table omits branch", function(assert)
		assert.eq(parsePublishBranch("[release]\n"), "publish-next-version")
	end)

	suite:case("rejects an empty branch", function(assert)
		assert.throws(function()
			parsePublishBranch('[release]\nbranch = ""\n')
		end)
	end)

	suite:case("rejects a non-string branch", function(assert)
		assert.throws(function()
			parsePublishBranch("[release]\nbranch = 1\n")
		end)
	end)
end)
