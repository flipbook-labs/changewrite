local test = require("@std/test")

local parseConfig = require("@root/release/parseConfig")

local function getError(source: string): string
	local success, err = pcall(parseConfig, source)
	assert(not success, "expected parseConfig to error")
	return tostring(err)
end

test.suite("parseConfig", function(suite)
	suite:case("returns the table the file returns", function(assert)
		local config = parseConfig('return {\n\tcategories = { "Features" },\n\tversion = { current = "1.2.3" },\n}\n')

		assert.eq((config.categories :: { string })[1], "Features")
		assert.eq((config.version :: any).current, "1.2.3")
	end)

	suite:case("lets a value come from a local", function(assert)
		local config = parseConfig([[
local purple = "#7c5cff"

return {
	kind = {
		engine = { text = "Engine", color = purple },
		runtime = { text = "Runtime", color = purple },
	},
}
]])

		assert.eq((config.kind :: any).runtime.color, "#7c5cff")
	end)

	suite:case("rejects a config that requires a module", function(assert)
		local err = getError('local fs = require("@std/fs")\n\nreturn {}\n')

		assert.strContains(err, "changewrite.luau failed to run")
		assert.strContains(err, "attempt to call a nil value")
	end)

	suite:case("rejects a file that doesn't return a table", function(assert)
		assert.strContains(getError("return 42\n"), "changewrite.luau must return a table of settings")
	end)

	suite:case("rejects a setting written without a name", function(assert)
		assert.strContains(getError('return { "Features" }\n'), "settings must be written as `name = value`")
	end)

	suite:case("rejects a snake_case setting", function(assert)
		assert.strContains(
			getError("return { max_summary_length = 120 }\n"),
			'Unknown field "max_summary_length" in changewrite.luau'
		)
	end)
end)
