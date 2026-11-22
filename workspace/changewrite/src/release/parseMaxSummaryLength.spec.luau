local test = require("@std/test")

local parseMaxSummaryLength = require("@root/release/parseMaxSummaryLength")

test.suite("parseMaxSummaryLength", function(suite)
	suite:case("defaults to 140 when the field is absent", function(assert)
		assert.eq(parseMaxSummaryLength('categories = ["Features"]'), 140)
	end)

	suite:case("reads the configured limit", function(assert)
		assert.eq(parseMaxSummaryLength("max_summary_length = 200"), 200)
	end)

	suite:case("rejects a limit that isn't a positive whole number", function(assert)
		for _, value in { "0", "-5", "12.5", '"long"' } do
			local success, err = pcall(parseMaxSummaryLength, `max_summary_length = {value}`)

			assert.eq(success, false)
			assert.strContains(tostring(err), "`max_summary_length` must be a positive whole number")
		end
	end)
end)
