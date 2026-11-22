local path = require("@std/path")
local test = require("@std/test")

local getVersionPattern = require("@root/release/getVersionPattern")

local PKG_MANIFEST = [[
return {
	package = {
		name = "AgentSkills",
		version = "0.7.0",
		dependencies = {},
	},
}
]]

test.suite("getVersionPattern", function(suite)
	suite:case("reads the version from pkg.luau without a configured pattern", function(assert)
		local pattern = getVersionPattern({ file = path.parse("pkg.luau") })

		assert.eq(PKG_MANIFEST:match(pattern), "0.7.0")
	end)

	suite:case("reads the version from a pkg.luau in a subfolder without a configured pattern", function(assert)
		local pattern = getVersionPattern({ file = path.parse("workspace/png/pkg.luau") })

		assert.eq(PKG_MANIFEST:match(pattern), "0.7.0")
	end)

	suite:case("prefers a configured pattern over the default", function(assert)
		local pattern = getVersionPattern({ file = path.parse("pkg.luau"), pattern = 'name = "(%w+)"' })

		assert.eq(PKG_MANIFEST:match(pattern), "AgentSkills")
	end)

	suite:case("throws for a file with no default and no configured pattern", function(assert)
		assert.throws(function()
			getVersionPattern({ file = path.parse("unknown.txt") })
		end)
	end)
end)
