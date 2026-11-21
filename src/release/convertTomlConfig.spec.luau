local test = require("@std/test")

local convertTomlConfig = require("@root/release/convertTomlConfig")
local parseConfig = require("@root/release/parseConfig")

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

	suite:case("keeps a kind named in snake_case as it is", function(assert)
		local config = parseConfig(convertTomlConfig([[
[kind.dev_tools]
text = "Dev tools"
color = "#6e7781"
]]))

		assert.neq((config.kind :: any).dev_tools, nil)
	end)
end)
