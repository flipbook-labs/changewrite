local test = require("@std/test")

local formatNumber = require("./formatNumber")

test.suite("formatNumber", function(suite)
	suite:case("drops trailing zeros and a bare decimal point", function(assert)
		assert.eq(formatNumber(1), "1")
		assert.eq(formatNumber(0.5), "0.5")
		assert.eq(formatNumber(12.10), "12.1")
	end)

	suite:case("rounds to two decimals", function(assert)
		assert.eq(formatNumber(1.234), "1.23")
		assert.eq(formatNumber(1.236), "1.24")
	end)

	suite:case("writes negative zero as zero", function(assert)
		assert.eq(formatNumber(-0.001), "0")
	end)
end)
