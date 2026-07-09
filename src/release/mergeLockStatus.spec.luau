local test = require("@std/test")

local mergeLockStatus = require("@root/release/mergeLockStatus")

test.suite("mergeLockStatus", function(suite)
	suite:case("builds the gh api call that posts the status", function(assert)
		local args = mergeLockStatus.buildStatusArgs({
			repo = "octocat/hello",
			sha = "abc123",
			state = "failure",
			context = "publish-lock",
			description = "out of date",
		})

		assert.eq(
			table.concat(args, " "),
			"api --method POST repos/octocat/hello/statuses/abc123"
				.. " -f state=failure -f context=publish-lock -f description=out of date"
		)
	end)

	suite:case("appends target_url only when a url is given", function(assert)
		local args = mergeLockStatus.buildStatusArgs({
			repo = "octocat/hello",
			sha = "abc123",
			state = "success",
			context = "publish-lock",
			description = "up to date",
			url = "https://example.test/run/1",
		})

		assert.eq(args[#args - 1], "-f")
		assert.eq(args[#args], "target_url=https://example.test/run/1")
	end)

	suite:case("uses a distinct message for each state", function(assert)
		assert.eq(mergeLockStatus.describe("failure") == mergeLockStatus.describe("success"), false)
	end)

	suite:case("reads a 404 from gh as a missing ref", function(assert)
		assert.eq(mergeLockStatus.isMissingRefError("gh: Not Found (HTTP 404)"), true)
	end)

	suite:case("does not read other gh failures as a missing ref", function(assert)
		assert.eq(mergeLockStatus.isMissingRefError("gh: Internal Server Error (HTTP 500)"), false)
		assert.eq(mergeLockStatus.isMissingRefError("dial tcp: lookup api.github.com: no such host"), false)
	end)
end)
