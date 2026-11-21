local test = require("@std/test")

local validateConfigFields = require("@root/release/validateConfigFields")

test.suite("validateConfigFields", function(suite)
	suite:case("rejects unknown top-level fields", function(assert)
		assert.throws(function()
			validateConfigFields({ unknown = "value", version = { current = "1.2.3" } })
		end)
	end)

	suite:case("accepts the summary length limit", function(assert)
		assert.never.throws(function()
			validateConfigFields({ maxSummaryLength = 120, version = { current = "1.2.3" } })
		end)
	end)

	suite:case("accepts the unreleased changes directory", function(assert)
		assert.never.throws(function()
			validateConfigFields({ unreleasedChanges = "changelog.d/" })
		end)
	end)

	suite:case("accepts the release branch", function(assert)
		assert.never.throws(function()
			validateConfigFields({ release = { branch = "release-next" }, version = { current = "1.2.3" } })
		end)
	end)

	suite:case("rejects unknown release fields", function(assert)
		assert.throws(function()
			validateConfigFields({ release = { branch = "release-next", unknown = "value" } })
		end)
	end)

	suite:case("rejects unknown version fields", function(assert)
		assert.throws(function()
			validateConfigFields({ version = { current = "1.2.3", unknown = "value" } })
		end)
	end)

	suite:case("rejects unknown mirror fields", function(assert)
		assert.throws(function()
			validateConfigFields({
				version = { current = "1.2.3", mirror = { { file = "wally.toml", unknown = "value" } } },
			})
		end)
	end)

	suite:case("rejects unknown single-mirror fields", function(assert)
		assert.throws(function()
			validateConfigFields({
				version = { current = "1.2.3", mirror = { file = "wally.toml", unknown = "value" } },
			})
		end)
	end)
end)
