local test = require("@std/test")

local parseCollapsedCategories = require("@root/release/parseCollapsedCategories")

test.suite("parseCollapsedCategories", function(suite)
	suite:case("collapses nothing when the field is absent", function(assert)
		assert.eq(#parseCollapsedCategories({ categories = { "Features" } }), 0)
	end)

	suite:case("reads collapsed categories in order", function(assert)
		local collapsed = parseCollapsedCategories({
			categories = { "Features", "Dependencies", "Internal" },
			collapsed = { "Internal", "Dependencies" },
		})

		assert.eq(#collapsed, 2)
		assert.eq(collapsed[1], "Internal")
		assert.eq(collapsed[2], "Dependencies")
	end)

	suite:case("rejects a collapsed category that isn't configured", function(assert)
		local success, err =
			pcall(parseCollapsedCategories, { categories = { "Features" }, collapsed = { "Internal" } })

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), 'Collapsed category "Internal" is not listed', 1, true), nil)
	end)
end)
