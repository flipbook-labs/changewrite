local test = require("@std/test")

local parseCollapsedVisible = require("@root/release/parseCollapsedVisible")

test.suite("parseCollapsedVisible", function(suite)
	suite:case("shows five entries when the field is absent", function(assert)
		assert.eq(parseCollapsedVisible({}), 5)
	end)

	suite:case("accepts zero, a whole number, or math.huge", function(assert)
		assert.eq(parseCollapsedVisible({ collapsedVisible = 0 }), 0)
		assert.eq(parseCollapsedVisible({ collapsedVisible = 12 }), 12)
		assert.eq(parseCollapsedVisible({ collapsedVisible = math.huge }), math.huge)
	end)

	suite:case("rejects a negative, fractional, or non-number count", function(assert)
		for _, value in { -1, 2.5, "5" } :: { unknown } do
			local success, err = pcall(parseCollapsedVisible, { collapsedVisible = value })

			assert.eq(success, false)
			assert.neq(tostring(err):find("`collapsedVisible` must be", 1, true), nil)
		end
	end)
end)
