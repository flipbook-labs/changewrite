local path = require("@std/path")
local test = require("@std/test")

local sortByAddedAt = require("@root/release/notes/sortByAddedAt")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function entry(body: string): UnreleasedChange
	return {
		bump = "patch",
		category = "Changes",
		summary = body,
		body = body,
		flags = {},
		file = path.parse(`{body}.md`),
	}
end

local function bodies(entries: { UnreleasedChange }): string
	local names: { string } = {}
	for _, change in entries do
		table.insert(names, change.body)
	end
	return table.concat(names, ",")
end

test.suite("sortByAddedAt", function(suite)
	suite:case("orders entries by when they merged, oldest first", function(assert)
		local a, b, c = entry("a"), entry("b"), entry("c")
		assert.eq(bodies(sortByAddedAt({ a, b, c }, { [a] = 30, [b] = 10, [c] = 20 })), "b,c,a")
	end)

	suite:case("puts uncommitted entries last, in their original order", function(assert)
		local a, b, c = entry("a"), entry("b"), entry("c")
		assert.eq(bodies(sortByAddedAt({ a, b, c }, { [b] = 10 })), "b,a,c")
	end)

	suite:case("keeps the original order for entries that merged together", function(assert)
		local a, b, c = entry("a"), entry("b"), entry("c")
		assert.eq(bodies(sortByAddedAt({ a, b, c }, { [a] = 10, [b] = 5, [c] = 10 })), "b,a,c")
	end)
end)
