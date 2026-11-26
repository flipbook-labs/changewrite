local test = require("@std/test")

local renderLuauConfig = require("@root/release/renderLuauConfig")
local runSandboxed = require("@root/runSandboxed")

test.suite("renderLuauConfig", function(suite)
	suite:case("puts the settings in their usual order and nests tables with tabs", function(assert)
		assert.eq(
			renderLuauConfig({
				version = { mirror = { { file = "pkg.luau" } }, current = "1.2.3" },
				categories = { "Features", "Fixes" },
			}),
			table.concat({
				"return {",
				'\tcategories = { "Features", "Fixes" },',
				"\tversion = {",
				'\t\tcurrent = "1.2.3",',
				"\t\tmirror = {",
				'\t\t\t{ file = "pkg.luau" },',
				"\t\t},",
				"\t},",
				"}",
				"",
			}, "\n")
		)
	end)

	suite:case("keeps a kind's fields on one line in their usual order", function(assert)
		assert.eq(
			renderLuauConfig({
				kind = {
					engine = { color = "#7c5cff", text = "Engine" },
					docs = { text = "Docs", color = "#bf8700", colorMode = { dark = { color = "#d29922" } } },
				},
			}),
			table.concat({
				"return {",
				"\tkind = {",
				"\t\tdocs = {",
				'\t\t\ttext = "Docs",',
				'\t\t\tcolor = "#bf8700",',
				"\t\t\tcolorMode = {",
				'\t\t\t\tdark = { color = "#d29922" },',
				"\t\t\t},",
				"\t\t},",
				'\t\tengine = { text = "Engine", color = "#7c5cff" },',
				"\t},",
				"}",
				"",
			}, "\n")
		)
	end)

	suite:case("quotes keys that aren't identifiers", function(assert)
		assert.strContains(renderLuauConfig({ kind = { ["dev-tools"] = { text = "Dev" } } }), '["dev-tools"] = {')
	end)

	suite:case("quotes a key that is a Luau keyword", function(assert)
		local loaded =
			runSandboxed(renderLuauConfig({ kind = { ["end"] = { text = "End" } } }), "config") :: { kind: { [string]: { text: string } } }

		assert.eq(loaded.kind["end"].text, "End")
	end)

	suite:case("writes strings that load back unchanged", function(assert)
		local value = 'version = "([^"]+)"\\n\twith \'both\' quotes\n'
		local loaded =
			runSandboxed(renderLuauConfig({ version = { pattern = value } }), "config") :: { version: { pattern: string } }

		assert.eq(loaded.version.pattern, value)
	end)

	suite:case("switches to single quotes for a string with only double quotes", function(assert)
		assert.strContains(renderLuauConfig({ version = { pattern = 'v"x"' } }), "pattern = 'v\"x\"'")
	end)

	suite:case("writes numbers as they are", function(assert)
		assert.strContains(renderLuauConfig({ maxSummaryLength = 120 }), "maxSummaryLength = 120,")
	end)
end)
