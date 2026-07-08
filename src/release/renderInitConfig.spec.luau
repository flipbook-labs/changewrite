local test = require("@std/test")

local renderInitConfig = require("@root/release/renderInitConfig")

test.suite("renderInitConfig", function(suite)
	suite:case("renders mirrors as an array of inline tables", function(assert)
		assert.eq(
			renderInitConfig("0.3.0", { "wally.toml", "Cargo.toml" }),
			table.concat({
				"[version]",
				'current = "0.3.0"',
				"mirror = [",
				'  { file = "wally.toml" },',
				'  { file = "Cargo.toml" },',
				"]",
				"",
			}, "\n")
		)
	end)

	suite:case("omits the mirror key when there are none", function(assert)
		assert.eq(
			renderInitConfig("0.1.0", {}),
			table.concat({
				"[version]",
				'current = "0.1.0"',
				"",
			}, "\n")
		)
	end)
end)
