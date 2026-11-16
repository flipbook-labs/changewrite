local test = require("@std/test")

local resolveUnlockState = require("@root/release/resolveUnlockState")

test.suite("resolveUnlockState", function(suite)
	suite:case("unlocks a branch head when no base commit is given", function(assert)
		local state = resolveUnlockState({
			sha = "publish1",
			isExplicitSha = false,
		})

		assert.eq(state, "success")
	end)

	suite:case("posts nothing when an explicit sha is the publish branch head", function(assert)
		local state = resolveUnlockState({
			sha = "publish1",
			isExplicitSha = true,
			publishHead = "publish1",
		})

		assert.eq(state, nil)
	end)

	suite:case("unlocks an explicit sha that is not the publish branch head", function(assert)
		local state = resolveUnlockState({
			sha = "feature1",
			isExplicitSha = true,
			publishHead = "publish1",
		})

		assert.eq(state, "success")
	end)

	suite:case("unlocks an explicit sha when there is no publish branch", function(assert)
		local state = resolveUnlockState({
			sha = "feature1",
			isExplicitSha = true,
			publishHead = nil,
		})

		assert.eq(state, "success")
	end)

	suite:case("unlocks when the base branch is still at the refreshed commit", function(assert)
		local state = resolveUnlockState({
			sha = "publish1",
			isExplicitSha = false,
			baseSha = "main1",
			baseHead = "main1",
		})

		assert.eq(state, "success")
	end)

	suite:case("locks when the base branch moved past the refreshed commit", function(assert)
		local state = resolveUnlockState({
			sha = "publish1",
			isExplicitSha = false,
			baseSha = "main1",
			baseHead = "main2",
		})

		assert.eq(state, "failure")
	end)

	suite:case("posts nothing for the publish head even when the base branch moved", function(assert)
		local state = resolveUnlockState({
			sha = "publish1",
			isExplicitSha = true,
			publishHead = "publish1",
			baseSha = "main1",
			baseHead = "main2",
		})

		assert.eq(state, nil)
	end)
end)
