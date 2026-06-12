local test = require("@std/test")

local evaluateReleaseGate = require("@root/release/evaluateReleaseGate")

test.suite("evaluateReleaseGate", function(suite)
	suite:case("force-publish always publishes the current version", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = true,
			tagExists = true,
			commitsSinceTag = 5,
		})
		assert.eq(result.shouldPublish, true)
		assert.eq(result.hasChanges, false)
		assert.eq(result.version, "1.2.3")
	end)

	suite:case("publishes when the current version has no tag yet", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = false,
			commitsSinceTag = 0,
		})
		assert.eq(result.shouldPublish, true)
		assert.eq(result.hasChanges, false)
	end)

	suite:case("does not publish a released version but flags unreleased commits", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = true,
			commitsSinceTag = 3,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, true)
	end)

	suite:case("reports no changes when a released version is at its tag", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = true,
			commitsSinceTag = 0,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, false)
	end)
end)
