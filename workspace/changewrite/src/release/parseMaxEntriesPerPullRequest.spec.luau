local test = require("@std/test")

local parseMaxEntriesPerPullRequest = require("@root/release/parseMaxEntriesPerPullRequest")

test.suite("parseMaxEntriesPerPullRequest", function(suite)
	suite:case("defaults to 1 when the field is absent", function(assert)
		assert.eq(parseMaxEntriesPerPullRequest({ categories = { "Features" } }), 1)
	end)

	suite:case("reads the configured limit", function(assert)
		assert.eq(parseMaxEntriesPerPullRequest({ maxEntriesPerPullRequest = 3 }), 3)
	end)

	suite:case("accepts math.huge to lift the limit", function(assert)
		assert.eq(parseMaxEntriesPerPullRequest({ maxEntriesPerPullRequest = math.huge }), math.huge)
	end)

	suite:case("rejects a limit that isn't a positive whole number", function(assert)
		for _, value in
			{
				0,
				-1,
				1.5,
				"one",
			} :: { unknown }
		do
			local success, err = pcall(parseMaxEntriesPerPullRequest, { maxEntriesPerPullRequest = value })

			assert.eq(success, false)
			assert.strContains(tostring(err), "`maxEntriesPerPullRequest` must be a positive whole number")
		end
	end)
end)
