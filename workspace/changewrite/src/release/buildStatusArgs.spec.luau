local test = require("@std/test")

local buildStatusArgs = require("@root/release/buildStatusArgs")

test.suite("buildStatusArgs", function(suite)
	suite:case("builds the gh api call that posts the status", function(assert)
		local args = buildStatusArgs({
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
		local args = buildStatusArgs({
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

	suite:case("omits target_url when the url is an empty string", function(assert)
		local args = buildStatusArgs({
			repo = "octocat/hello",
			sha = "abc123",
			state = "success",
			context = "publish-lock",
			description = "up to date",
			url = "",
		})

		assert.eq(table.find(args, "-f") ~= nil, true)
		assert.eq(table.concat(args, " "):find("target_url", 1, true), nil)
	end)
end)
