local test = require("@std/test")

local parseVersionConfig = require("@root/release/parseVersionConfig")

test.suite("parseVersionConfig", function(suite)
	suite:case("defaults to changewrite.luau as the version source", function(assert)
		local config = parseVersionConfig({ version = { current = "1.2.3" } })

		assert.eq(config.current, "1.2.3")
		assert.eq(tostring(config.source.file), "changewrite.luau")
	end)

	suite:case("defaults the unreleased changes directory to ./.changes/", function(assert)
		local config = parseVersionConfig({ version = { current = "1.2.3" } })

		assert.eq(tostring(config.unreleasedChangesDir), "./.changes")
	end)

	suite:case("reads an explicit unreleasedChanges directory", function(assert)
		local config = parseVersionConfig({ unreleasedChanges = "changelog.d/", version = { current = "1.2.3" } })

		assert.eq(tostring(config.unreleasedChangesDir), "changelog.d")
	end)

	suite:case("reads an explicit source file and mirror targets", function(assert)
		local config = parseVersionConfig({
			version = {
				file = "wally.toml",
				pattern = 'version = "([^"]+)"',
				mirror = {
					{ file = "loom.config.luau" },
					{ file = "package.json", pattern = '"version"%s*:%s*"([^"]+)"' },
				},
			},
		})

		assert.eq(tostring(config.source.file), "wally.toml")
		assert.eq(config.source.pattern, 'version = "([^"]+)"')
		assert.eq(#config.mirrors, 2)
		assert.eq(tostring(config.mirrors[1].file), "loom.config.luau")
		assert.eq(tostring(config.mirrors[2].file), "package.json")
		assert.eq(config.mirrors[2].pattern, '"version"%s*:%s*"([^"]+)"')
	end)

	suite:case("accepts a single mirror table", function(assert)
		local config = parseVersionConfig({ version = { current = "1.0.0", mirror = { file = "loom.config.luau" } } })

		assert.eq(#config.mirrors, 1)
		assert.eq(tostring(config.mirrors[1].file), "loom.config.luau")
	end)
end)
