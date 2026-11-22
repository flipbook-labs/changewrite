local test = require("@std/test")

local deriveDarkColor = require("@root/chips/deriveDarkColor")

test.suite("deriveDarkColor", function(suite)
	suite:case("keeps the hue and chroma and raises the lightness", function(assert)
		assert.eq(deriveDarkColor("#0e7490"), "#4ea5c2")
		assert.eq(deriveDarkColor("#6b7380"), "#9ba3b1")
	end)

	suite:case("reduces chroma when the lighter color falls outside sRGB", function(assert)
		assert.eq(deriveDarkColor("#bc4c00"), "#f37e46")
		assert.eq(deriveDarkColor("#c8264b"), "#ff647a")
	end)

	suite:case("tops out at white", function(assert)
		assert.eq(deriveDarkColor("#ffffff"), "#ffffff")
		assert.eq(deriveDarkColor("#00ff00"), "#ffffff")
	end)
end)
