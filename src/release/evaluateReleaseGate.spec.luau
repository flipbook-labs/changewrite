local test = require("@std/test")

local evaluateReleaseGate = require("@root/release/evaluateReleaseGate")

test.suite("evaluateReleaseGate", function(suite)
	suite:case("force-publish always publishes the current version", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = true,
			tagExists = true,
			hasUnreleasedChanges = true,
		})
		assert.eq(result.shouldPublish, true)
		assert.eq(result.hasChanges, false)
		assert.eq(result.version, "1.2.3")
	end)

	suite:case("prepares a PR when there are pending changes", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = true,
			hasUnreleasedChanges = true,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, true)
	end)

	suite:case("prepares the first release before it is tagged", function(assert)
		local result = evaluateReleaseGate({
			version = "0.1.0",
			forcePublish = false,
			tagExists = false,
			hasUnreleasedChanges = true,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, true)
	end)

	suite:case("publishes a prepared version once its changes are consumed", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = false,
			hasUnreleasedChanges = false,
		})
		assert.eq(result.shouldPublish, true)
		assert.eq(result.hasChanges, false)
	end)

	suite:case("reports nothing to do for a released version with no changes", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = true,
			hasUnreleasedChanges = false,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, false)
	end)
end)
