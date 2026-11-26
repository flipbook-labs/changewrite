local test = require("@std/test")

local convertTomlConfig = require("@root/release/convertTomlConfig")
local parseConfig = require("@root/release/parseConfig")

type VersionTarget = {
	file: string,
	pattern: string?,
}

type VersionConfig = {
	file: string,
	pattern: string?,
	mirror: { VersionTarget },
}

test.suite("convertTomlConfig", function(suite)
	suite:case("converts each table to Luau", function(assert)
		local converted = convertTomlConfig([[
categories = ["Features", "Fixes"]

[version]
current = "0.13.0"
mirror = [
  { file = "pkg.luau" },
]

[kind]
cli = { text = "CLI", color = "#1f883d" }
]])

		assert.eq(
			converted,
			table.concat({
				"return {",
				'\tcategories = { "Features", "Fixes" },',
				"\tversion = {",
				'\t\tcurrent = "0.13.0",',
				"\t\tmirror = {",
				'\t\t\t{ file = "pkg.luau" },',
				"\t\t},",
				"\t},",
				"\tkind = {",
				'\t\tcli = { text = "CLI", color = "#1f883d" },',
				"\t},",
				"}",
				"",
			}, "\n")
		)
	end)

	suite:case("renames snake_case settings to camelCase", function(assert)
		local config = parseConfig(convertTomlConfig([[
unreleased_changes = "changelog.d/"
max_summary_length = 120
]]))

		assert.eq(config.unreleasedChanges, "changelog.d/")
		assert.eq(config.maxSummaryLength, 120)
		assert.eq(config.unreleased_changes, nil)
	end)

	suite:case("writes a flag table's name as the flag is now spelled", function(assert)
		local config = parseConfig(convertTomlConfig([[
[flag.breaking]
text = "Heads up"
]]))

		assert.eq((config.flag :: { [string]: { text: string } }).Breaking.text, "Heads up")
		assert.eq((config.flag :: { [string]: { text: string } }).breaking, nil)
	end)

	suite:case("keeps a kind named in snake_case as it is", function(assert)
		local config = parseConfig(convertTomlConfig([[
[kind.dev_tools]
text = "Dev tools"
color = "#6e7781"
]]))

		assert.neq((config.kind :: { [string]: unknown }).dev_tools, nil)
	end)

	suite:case("points a version target at the new file when it named changewrite.toml", function(assert)
		local config = parseConfig(convertTomlConfig([[
[version]
current = "1.0.0"
file = "changewrite.toml"
pattern = 'current = "([^"]+)"'
mirror = [
  { file = "wally.toml" },
  { file = "changewrite.toml", pattern = 'current = "([^"]+)"' },
]
]])) :: { version: VersionConfig }

		assert.eq(config.version.file, "changewrite.luau")
		assert.eq(config.version.pattern, nil)
		assert.eq(config.version.mirror[1].file, "wally.toml")
		assert.eq(config.version.mirror[2].file, "changewrite.luau")
		assert.eq(config.version.mirror[2].pattern, nil)
	end)

	suite:case("points a single mirror table at the new file", function(assert)
		local config = parseConfig(convertTomlConfig([[
[version]
file = "wally.toml"
mirror = { file = "changewrite.toml" }
]])) :: { version: { mirror: VersionTarget } }

		assert.eq(config.version.mirror.file, "changewrite.luau")
	end)
end)
