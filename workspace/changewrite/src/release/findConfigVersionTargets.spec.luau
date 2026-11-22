local path = require("@std/path")
local test = require("@std/test")

local findConfigVersionTargets = require("@root/release/findConfigVersionTargets")
local types = require("@root/release/types")

local function configWith(source: types.VersionTarget, mirrors: { types.VersionTarget }): types.VersionConfig
	return {
		current = "1.0.0",
		source = source,
		mirrors = mirrors,
		unreleasedChangesDir = path.parse(".changes"),
	}
end

test.suite("findConfigVersionTargets", function(suite)
	suite:case("finds changewrite.luau as the version source", function(assert)
		local config = configWith({ file = path.parse("changewrite.luau") }, { { file = path.parse("pkg.luau") } })

		assert.eq(#findConfigVersionTargets(config), 1)
	end)

	suite:case("finds changewrite.luau as a mirror", function(assert)
		local config = configWith({ file = path.parse("wally.toml") }, { { file = path.parse("changewrite.luau") } })
		local targets = findConfigVersionTargets(config)

		assert.eq(#targets, 1)
		assert.eq(tostring(targets[1].file), "changewrite.luau")
	end)

	suite:case("skips a target with its own pattern", function(assert)
		local config = configWith({ file = path.parse("changewrite.luau"), pattern = 'v = "(.-)"' }, {})

		assert.eq(#findConfigVersionTargets(config), 0)
	end)
end)
