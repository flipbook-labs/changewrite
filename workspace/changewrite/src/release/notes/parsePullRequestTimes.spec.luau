local test = require("@std/test")

local parsePullRequestTimes = require("@root/release/notes/parsePullRequestTimes")

test.suite("parsePullRequestTimes", function(suite)
	suite:case("reads squash merge subjects", function(assert)
		local times = parsePullRequestTimes("200 Add a thing (#42)\n100 Fix a bug (#7)\n")
		assert.eq(times[42], 200)
		assert.eq(times[7], 100)
	end)

	suite:case("reads merge commit subjects", function(assert)
		local times = parsePullRequestTimes("300 Merge pull request #42 from someone/branch\n")
		assert.eq(times[42], 300)
	end)

	suite:case("skips subjects that only mention a number", function(assert)
		local times = parsePullRequestTimes("300 Follow up on #42\n200 Revert (#42) partly\n")
		assert.eq(times[42], nil)
	end)

	suite:case("keeps similar numbers apart", function(assert)
		local times = parsePullRequestTimes("300 Add another thing (#420)\n200 Add a thing (#42)\n")
		assert.eq(times[42], 200)
		assert.eq(times[420], 300)
	end)

	suite:case("uses the earliest commit when a subject repeats", function(assert)
		local times = parsePullRequestTimes("300 Add a thing (#42)\n100 Add a thing (#42)\n")
		assert.eq(times[42], 100)
	end)

	suite:case("returns nothing for an empty log", function(assert)
		assert.eq(next(parsePullRequestTimes("")), nil)
	end)
end)
