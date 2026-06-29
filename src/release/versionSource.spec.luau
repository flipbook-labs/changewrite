local test = require("@std/test")

local versionSource = require("@root/release/versionSource")

test.suite("versionSource config", function(suite)
	suite:case("defaults to changewrite.toml as the version source", function(assert)
		local config = versionSource._parseConfigText([[
[version]
current = "1.2.3"
]])

		assert.eq(config.current, "1.2.3")
		assert.eq(config.source.file, "changewrite.toml")
	end)

	suite:case("defaults the change partials directory to ./.changes/", function(assert)
		local config = versionSource._parseConfigText([[
[version]
current = "1.2.3"
]])

		assert.eq(config.changePartialsDir, "./.changes/")
	end)

	suite:case("reads an explicit change_partials directory", function(assert)
		local config = versionSource._parseConfigText([[
change_partials = "changelog.d/"

[version]
current = "1.2.3"
]])

		assert.eq(config.changePartialsDir, "changelog.d/")
	end)

	suite:case("reads an explicit source file and mirror targets", function(assert)
		local config = versionSource._parseConfigText([[
[version]
file = "wally.toml"
pattern = 'version = "([^"]+)"'
mirror = [
  { file = "loom.config.luau" },
  { file = "package.json", pattern = '"version"%s*:%s*"([^"]+)"' },
]
]])

		assert.eq(config.source.file, "wally.toml")
		assert.eq(config.source.pattern, 'version = "([^"]+)"')
		assert.eq(#config.mirrors, 2)
		assert.eq(config.mirrors[1].file, "loom.config.luau")
		assert.eq(config.mirrors[2].file, "package.json")
	end)
end)
