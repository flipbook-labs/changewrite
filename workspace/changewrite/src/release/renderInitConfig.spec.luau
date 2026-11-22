local path = require("@std/path")
local test = require("@std/test")

local renderInitConfig = require("@root/release/renderInitConfig")

test.suite("renderInitConfig", function(suite)
	suite:case("renders each mirror as a table in a list", function(assert)
		assert.eq(
			renderInitConfig("0.3.0", { path.parse("wally.toml"), path.parse("Cargo.toml") }),
			table.concat({
				"return {",
				'\tcategories = { "Features", "Fixes", "Changes", "Dependencies" },',
				"\tversion = {",
				'\t\tcurrent = "0.3.0",',
				"\t\tmirror = {",
				'\t\t\t{ file = "wally.toml" },',
				'\t\t\t{ file = "Cargo.toml" },',
				"\t\t},",
				"\t},",
				"}",
				"",
			}, "\n")
		)
	end)

	suite:case("omits the mirror key when there are none", function(assert)
		assert.eq(
			renderInitConfig("0.1.0", {}),
			table.concat({
				"return {",
				'\tcategories = { "Features", "Fixes", "Changes", "Dependencies" },',
				'\tversion = { current = "0.1.0" },',
				"}",
				"",
			}, "\n")
		)
	end)
end)
