local test = require("@std/test")

local parseCategories = require("@root/release/parseCategories")

test.suite("parseCategories", function(suite)
	suite:case("reads configured changelog categories", function(assert)
		local text = [[
categories = ["Features", "Fixes", "Changes"]

[version]
current = "1.2.3"
]]

		assert.eq(parseCategories(text), { "Features", "Fixes", "Changes" })
	end)

	suite:case("rejects a category map", function(assert)
		local text = [[
categories = { intended = "Features" }

[version]
current = "1.2.3"
]]

		assert.throws(function()
			parseCategories(text)
		end)
	end)

	suite:case("omits changelog categories when they are not configured", function(assert)
		local text = [[
[version]
current = "1.2.3"
]]

		assert.eq(parseCategories(text), nil)
	end)
end)
