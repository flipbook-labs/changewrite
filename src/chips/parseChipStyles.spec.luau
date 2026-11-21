local test = require("@std/test")

local parseChipStyles = require("@root/chips/parseChipStyles")
local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle

local function find(styles: { ChipStyle }, group: string, name: string): ChipStyle
	for _, style in styles do
		if style.group == group and style.name == name then
			return style
		end
	end
	error(`No style for {group}/{name}`)
end

test.suite("parseChipStyles", function(suite)
	suite:case("reads each kind, in alphabetical order, then every flag", function(assert)
		local styles = parseChipStyles({
			kind = {
				engine = { text = "Engine", color = "#7C5CFF" },
				docs = { text = "Docs", color = "#2da44e" },
			},
		})

		local keys: { string } = {}
		for _, style in styles do
			table.insert(keys, `{style.group}/{style.name}`)
		end
		assert.eq(table.concat(keys, " "), "kind/docs kind/engine flag/breaking flag/deprecated flag/security")

		local engine = find(styles, "kind", "engine")
		assert.eq(engine.text, "Engine")
		assert.eq(engine.colorMode.light.color, "#7c5cff")
		assert.eq(engine.colorMode.light.textColor, nil)
	end)

	suite:case("derives the dark color from the light one when none is set", function(assert)
		local styles = parseChipStyles({ kind = { sidebar = { text = "Sidebar", color = "#0e7490" } } })

		local sidebar = find(styles, "kind", "sidebar")
		assert.eq(sidebar.colorMode.light.color, "#0e7490")
		assert.eq(sidebar.colorMode.dark.color, "#4ea5c2")
	end)

	suite:case("overrides a color for one color mode", function(assert)
		local styles = parseChipStyles({
			kind = {
				engine = {
					text = "Engine",
					color = "#7c5cff",
					textColor = "#111111",
					colorMode = { dark = { color = "#a28bff", textColor = "#eeeeee" } },
				},
			},
		})

		local engine = find(styles, "kind", "engine")
		assert.eq(engine.colorMode.light.color, "#7c5cff")
		assert.eq(engine.colorMode.light.textColor, "#111111")
		assert.eq(engine.colorMode.dark.color, "#a28bff")
		assert.eq(engine.colorMode.dark.textColor, "#eeeeee")
	end)

	suite:case("restyles a flag over its built-in style", function(assert)
		local styles = parseChipStyles({ flag = { breaking = { text = "Heads up" } } })

		local breaking = find(styles, "flag", "breaking")
		assert.eq(breaking.text, "Heads up")
		assert.eq(breaking.colorMode.light.color, "#c8264b")
		assert.eq(breaking.colorMode.dark.color, "#ff647a")

		local security = find(styles, "flag", "security")
		assert.eq(security.colorMode.dark.color, "#ff8c46")
	end)

	suite:case("derives a dark color for a flag given a new color", function(assert)
		local styles = parseChipStyles({ flag = { security = { color = "#bc4c00" } } })

		local security = find(styles, "flag", "security")
		assert.eq(security.colorMode.light.color, "#bc4c00")
		assert.eq(security.colorMode.dark.color, "#f37e46")
	end)

	suite:case("gives every flag its built-in style with no config", function(assert)
		local styles = parseChipStyles({ categories = { "Features" } })

		assert.eq(#styles, 3)
		assert.eq(find(styles, "flag", "security").text, "Security")
	end)

	suite:case("rejects a kind without a text or color", function(assert)
		assert.throws(function()
			parseChipStyles({ kind = { engine = { color = "#7c5cff" } } })
		end)
		assert.throws(function()
			parseChipStyles({ kind = { engine = { text = "Engine" } } })
		end)
	end)

	suite:case("rejects a color that isn't a six-digit hex color", function(assert)
		local success, err = pcall(parseChipStyles, { kind = { engine = { text = "Engine", color = "purple" } } })

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), "must be a hex color", 1, true), nil)
	end)

	suite:case("rejects an unknown flag or field", function(assert)
		local flagSuccess, flagErr = pcall(parseChipStyles, { flag = { api = { text = "API" } } })
		assert.eq(flagSuccess, false)
		assert.neq(string.find(tostring(flagErr), "`flag.api` is not a flag", 1, true), nil)

		assert.throws(function()
			parseChipStyles({ kind = { engine = { text = "Engine", color = "#7c5cff", label = "Engine" } } })
		end)
	end)

	suite:case("rejects kinds whose names differ only by case", function(assert)
		local success, err = pcall(parseChipStyles, {
			kind = {
				App = { text = "App", color = "#7c5cff" },
				app = { text = "App", color = "#2da44e" },
			},
		})

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), "`kind.app` and `kind.App` differ only by case", 1, true), nil)
	end)
end)
