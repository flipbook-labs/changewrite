local test = require("@std/test")

local evaluateReleaseGate = require("@root/release/evaluateReleaseGate")

test.suite("evaluateReleaseGate", function(suite)
	suite:case("force-publish always publishes the current version", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = true,
			tagExists = true,
			hasPartials = true,
		})
		assert.eq(result.shouldPublish, true)
		assert.eq(result.hasChanges, false)
		assert.eq(result.version, "1.2.3")
	end)

	suite:case("prepares a PR when there are pending partials", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = true,
			hasPartials = true,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, true)
	end)

	suite:case("prepares the first release before it is tagged", function(assert)
		local result = evaluateReleaseGate({
			version = "0.1.0",
			forcePublish = false,
			tagExists = false,
			hasPartials = true,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, true)
	end)

	suite:case("publishes a prepared version once its partials are consumed", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = false,
			hasPartials = false,
		})
		assert.eq(result.shouldPublish, true)
		assert.eq(result.hasChanges, false)
	end)

	suite:case("reports nothing to do for a released version with no partials", function(assert)
		local result = evaluateReleaseGate({
			version = "1.2.3",
			forcePublish = false,
			tagExists = true,
			hasPartials = false,
		})
		assert.eq(result.shouldPublish, false)
		assert.eq(result.hasChanges, false)
	end)
end)
