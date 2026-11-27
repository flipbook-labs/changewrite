local test = require("@std/test")

local parseCommentIds = require("@root/release/parseCommentIds")

test.suite("parseCommentIds", function(suite)
	suite:case("reads one id per line in order", function(assert)
		assert.eq(parseCommentIds("7226931502\n7226977071\n"), {
			7226931502,
			7226977071,
		})
	end)

	suite:case("reads no ids when gh prints nothing", function(assert)
		assert.eq(parseCommentIds(""), {})
	end)

	suite:case("fails on a line that isn't a number", function(assert)
		assert.throws(function()
			parseCommentIds("12\nnot-an-id\n")
		end)
	end)
end)
