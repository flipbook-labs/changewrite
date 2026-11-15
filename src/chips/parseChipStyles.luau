local toml = require("@batteries/toml")

local assertKnownFields = require("@root/release/assertKnownFields")
local constants = require("@root/release/constants")
local deriveDarkColor = require("@root/chips/deriveDarkColor")
local flagStyles = require("@root/chips/flagStyles")
local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle
type ColorModeStyle = types.ColorModeStyle
type TomlTable = { [string]: toml.TomlValue }

local STYLE_FIELDS = { text = true, color = true, textColor = true, colorMode = true }
local COLOR_MODE_FIELDS = { light = true, dark = true }
local COLOR_MODE_STYLE_FIELDS = { color = true, textColor = true }

local function asTable(value: unknown, context: string): TomlTable
	assert(typeof(value) == "table", `{context} must be a table`)
	return value :: any
end

local function readString(value: toml.TomlValue?, context: string): string?
	if value == nil then
		return nil
	end
	assert(typeof(value) == "string" and value ~= "", `{context} must be a non-empty string`)
	return value :: string
end

local function readColor(value: toml.TomlValue?, context: string): string?
	local color = readString(value, context)
	if color then
		assert(color:match("^#%x%x%x%x%x%x$"), `{context} must be a hex color such as "#7c5cff"`)
		return color:lower()
	end
	return nil
end

-- Lays a table's fields over a base style. Top-level `color` and `textColor`
-- apply to the light color mode, and `textColor` to the dark one too. A
-- `colorMode.light` or `colorMode.dark` table sets either field for that mode
-- alone. When the table sets a light color but no dark one, the dark color
-- comes from deriveDarkColor. A table that sets no color at all keeps the base
-- style's colors.
local function applyFields(base: ChipStyle, fields: TomlTable, context: string): ChipStyle
	assertKnownFields(fields, STYLE_FIELDS, context)

	local text = readString(fields.text, `{context} text`) or base.text
	local color = readColor(fields.color, `{context} color`)
	local textColor = readColor(fields.textColor, `{context} textColor`)

	local modes: TomlTable = if fields.colorMode ~= nil then asTable(fields.colorMode, `{context} colorMode`) else {}
	assertKnownFields(modes, COLOR_MODE_FIELDS, `{context} colorMode`)

	local function readMode(name: "light" | "dark"): (string?, string?)
		if modes[name] == nil then
			return nil, nil
		end
		local modeContext = `{context} colorMode.{name}`
		local mode = asTable(modes[name], modeContext)
		assertKnownFields(mode, COLOR_MODE_STYLE_FIELDS, modeContext)
		return readColor(mode.color, `{modeContext} color`), readColor(mode.textColor, `{modeContext} textColor`)
	end

	local lightColor, lightTextColor = readMode("light")
	local darkColor, darkTextColor = readMode("dark")

	local light: ColorModeStyle = {
		color = lightColor or color or base.colorMode.light.color,
		textColor = lightTextColor or textColor or base.colorMode.light.textColor,
	}
	assert(light.color ~= "", `{context} needs a color`)

	-- Deriving here, rather than keeping the base style's dark color, matters
	-- for flags: their built-in dark colors were picked for their built-in
	-- light colors.
	local setsLightColor = lightColor ~= nil or color ~= nil
	local dark: ColorModeStyle = {
		color = darkColor or if setsLightColor then deriveDarkColor(light.color) else base.colorMode.dark.color,
		textColor = darkTextColor or textColor or base.colorMode.dark.textColor,
	}
	assert(dark.color ~= "", `{context} needs a color`)

	return {
		group = base.group,
		name = base.name,
		text = text,
		colorMode = {
			light = light,
			dark = dark,
		},
	}
end

local function sortedKeys(value: TomlTable): { string }
	local keys: { string } = {}
	for key in value do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

-- Reads every chip changewrite.toml describes: each configured kind, in
-- alphabetical order, then every flag in its usual order.
local function parseChipStyles(text: string): { ChipStyle }
	local parsed = toml.deserialize(text)
	local styles: { ChipStyle } = {}

	if parsed.kind ~= nil then
		local kinds = asTable(parsed.kind, "`kind`")
		for _, name in sortedKeys(kinds) do
			local context = `[kind.{name}]`
			assert(name:match("^[%w_-]+$"), `{context} must be named with letters, digits, "-", or "_"`)
			local fields = asTable(kinds[name], context)
			assert(fields.text ~= nil, `{context} needs a text`)
			assert(fields.color ~= nil, `{context} needs a color`)
			table.insert(
				styles,
				applyFields({
					group = "kind",
					name = name,
					text = "",
					colorMode = {
						light = { color = "" },
						dark = { color = "" },
					},
				}, fields, context)
			)
		end
	end

	local flags: TomlTable = if parsed.flag ~= nil then asTable(parsed.flag, "`flag`") else {}
	for name in flags do
		assert(
			flagStyles[name] ~= nil,
			`[flag.{name}] is not a flag. Expected one of: {table.concat(constants.CHANGE_FLAGS, ", ")}`
		)
	end
	for _, name in constants.CHANGE_FLAGS do
		local base = flagStyles[name]
		if flags[name] ~= nil then
			local context = `[flag.{name}]`
			table.insert(styles, applyFields(base, asTable(flags[name], context), context))
		else
			table.insert(styles, base)
		end
	end

	return styles
end

return parseChipStyles
