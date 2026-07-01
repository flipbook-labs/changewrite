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
		assert.eq(config.mirrors[2].pattern, '"version"%s*:%s*"([^"]+)"')
	end)

	suite:case("ignores comments and surrounding whitespace", function(assert)
		local config = versionSource._parseConfigText([[
# leading comment
[version]
current = "4.5.6" # inline comment
]])

		assert.eq(config.current, "4.5.6")
		assert.eq(config.source.file, "changewrite.toml")
	end)
end)
