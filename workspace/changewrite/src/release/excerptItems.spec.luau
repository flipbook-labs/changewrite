local test = require("@std/test")

local excerptItems = require("@root/release/excerptItems")

local ITEMS = string.split("abcdefg", "")

-- Focus flags for ITEMS with only the items at these positions focused.
local function focusAt(...: number): { boolean }
	local focused: { boolean } = {}
	for index = 1, #ITEMS do
		focused[index] = table.find({ ... }, index) ~= nil
	end
	return focused
end

test.suite("excerptItems", function(suite)
	suite:case("keeps the neighbors on each side and marks the cuts at both ends", function(assert)
		local excerpt = excerptItems(ITEMS, focusAt(4), 1)

		assert.eq(table.concat(excerpt or {}, " "), "… c d e …")
	end)

	suite:case("marks a run of left-out items with one cut between two kept groups", function(assert)
		local excerpt = excerptItems(ITEMS, focusAt(1, 7), 1)

		assert.eq(table.concat(excerpt or {}, " "), "a b … f g")
	end)

	suite:case("leaves no cut where two focused items' neighbors meet", function(assert)
		local excerpt = excerptItems(ITEMS, focusAt(2, 4), 1)

		assert.eq(table.concat(excerpt or {}, " "), "a b c d e …")
	end)

	suite:case("keeps only the focused items when there are no neighbors", function(assert)
		local excerpt = excerptItems(ITEMS, focusAt(3), 0)

		assert.eq(table.concat(excerpt or {}, " "), "… c …")
	end)

	suite:case("returns nil when no item is focused", function(assert)
		assert.eq(excerptItems(ITEMS, focusAt(), 1), nil)
	end)
end)
