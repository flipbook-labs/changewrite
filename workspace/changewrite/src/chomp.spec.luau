local test = require("@std/test")

local chomp = require("@root/chomp")

test.suite("chomp", function(suite)
	suite:case("strips a trailing newline", function(assert)
		assert.eq(chomp("abc123\n"), "abc123")
	end)

	suite:case("strips trailing whitespace of any kind", function(assert)
		assert.eq(chomp("abc123 \t\n\n"), "abc123")
	end)

	suite:case("strips leading whitespace", function(assert)
		assert.eq(chomp("  \tabc123"), "abc123")
	end)

	suite:case("leaves interior whitespace alone", function(assert)
		assert.eq(chomp("  a b\tc\n"), "a b\tc")
	end)

	suite:case("returns an empty string when the input is all whitespace", function(assert)
		assert.eq(chomp("  \n"), "")
	end)
end)
