local test = require("@std/test")

local parseCategories = require("@root/release/parseCategories")

test.suite("parseCategories", function(suite)
	suite:case("reads configured changelog categories", function(assert)
		local config = { categories = { "Features", "Fixes", "Changes" }, version = { current = "1.2.3" } }

		assert.eq(parseCategories(config), { "Features", "Fixes", "Changes" })
	end)

	suite:case("rejects a category map", function(assert)
		assert.throws(function()
			parseCategories({ categories = { intended = "Features" } })
		end)
	end)

	suite:case("omits changelog categories when they are not configured", function(assert)
		assert.eq(parseCategories({ version = { current = "1.2.3" } }), nil)
	end)
end)
