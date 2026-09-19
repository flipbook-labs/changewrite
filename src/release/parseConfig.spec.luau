local test = require("@std/test")

local parseConfig = require("@root/release/parseConfig")

test.suite("parseConfig", function(suite)
	suite:case("defaults to changewrite.toml as the version source", function(assert)
		local text = [[
[version]
current = "1.2.3"
]]
		local config = parseConfig(text)

		assert.eq(config.current, "1.2.3")
		assert.eq(config.source.file, "changewrite.toml")
	end)

	suite:case("defaults the unreleased changes directory to ./.changes/", function(assert)
		local text = [[
[version]
current = "1.2.3"
]]
		local config = parseConfig(text)

		assert.eq(config.unreleasedChangesDir, "./.changes/")
	end)

	suite:case("reads an explicit unreleased_changes directory", function(assert)
		local text = [[
unreleased_changes = "changelog.d/"

[version]
current = "1.2.3"
]]
		local config = parseConfig(text)

		assert.eq(config.unreleasedChangesDir, "changelog.d/")
	end)

	suite:case("reads configured changelog categories", function(assert)
		local text = [[
categories = ["Features", "Fixes", "Changes"]

[version]
current = "1.2.3"
]]
		local config = parseConfig(text)

		assert.eq(config.categories, { "Features", "Fixes", "Changes" })
	end)

	suite:case("rejects a category map", function(assert)
		local text = [[
categories = { intended = "Features" }

[version]
current = "1.2.3"
]]

		assert.throws(function()
			parseConfig(text)
		end)
	end)

	suite:case("omits changelog categories when they are not configured", function(assert)
		local text = [[
[version]
current = "1.2.3"
]]
		local config = parseConfig(text)

		assert.eq(config.categories, nil)
	end)

	suite:case("reads an explicit source file and mirror targets", function(assert)
		local text = [[
[version]
file = "wally.toml"
pattern = 'version = "([^"]+)"'
mirror = [
  { file = "loom.config.luau" },
  { file = "package.json", pattern = '"version"%s*:%s*"([^"]+)"' },
]
]]
		local config = parseConfig(text)

		assert.eq(config.source.file, "wally.toml")
		assert.eq(config.source.pattern, 'version = "([^"]+)"')
		assert.eq(#config.mirrors, 2)
		assert.eq(config.mirrors[1].file, "loom.config.luau")
		assert.eq(config.mirrors[2].file, "package.json")
		assert.eq(config.mirrors[2].pattern, '"version"%s*:%s*"([^"]+)"')
	end)

	suite:case("accepts a single inline-table mirror", function(assert)
		local text = [[
[version]
current = "1.0.0"
mirror = { file = "loom.config.luau" }
]]
		local config = parseConfig(text)

		assert.eq(#config.mirrors, 1)
		assert.eq(config.mirrors[1].file, "loom.config.luau")
	end)

	suite:case("ignores comments and surrounding whitespace", function(assert)
		local text = [[
# leading comment
[version]
current = "4.5.6" # inline comment
]]
		local config = parseConfig(text)

		assert.eq(config.current, "4.5.6")
		assert.eq(config.source.file, "changewrite.toml")
	end)
end)
