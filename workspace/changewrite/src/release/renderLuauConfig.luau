-- Writes a config table as the source of a changewrite.luau, for `init` and
-- for converting a changewrite.toml. A short table of plain values, such as a
-- kind or a list of categories, stays on one line. The limit counts the
-- table and its indent but not the key in front of it, so a line can run a
-- little past it. Anything else gets a line per field, indented with tabs.

local MAX_INLINE_WIDTH = 100

-- Settings come out in this order, and fields of the tables inside them too,
-- so a converted config reads like a hand-written one. Any other key follows,
-- sorted, since a TOML file's own order is lost when it's read.
local KEY_ORDER: { string } = {
	"categories",
	"collapsed",
	"unreleasedChanges",
	"maxSummaryLength",
	"version",
	"release",
	"kind",
	"flag",
	"current",
	"file",
	"pattern",
	"mirror",
	"branch",
	"text",
	"color",
	"textColor",
	"colorMode",
	"light",
	"dark",
}

local RESERVED_WORDS: { [string]: boolean } = {}
for _, word in
	{
		"and",
		"break",
		"do",
		"else",
		"elseif",
		"end",
		"false",
		"for",
		"function",
		"if",
		"in",
		"local",
		"nil",
		"not",
		"or",
		"repeat",
		"return",
		"then",
		"true",
		"until",
		"while",
	}
do
	RESERVED_WORDS[word] = true
end

local function renderString(value: string): string
	-- Prefer double quotes, and switch to single quotes for a value such as a
	-- version pattern that holds double quotes and no single ones.
	local quote = if value:find('"', 1, true) and not value:find("'", 1, true) then "'" else '"'
	local escaped =
		value:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"):gsub(quote, "\\" .. quote)
	return quote .. escaped .. quote
end

local function renderKey(key: string): string
	if key:match("^[%a_][%w_]*$") and not RESERVED_WORDS[key] then
		return key
	end
	return `[{renderString(key)}]`
end

local function isList(value: { [unknown]: unknown }): boolean
	local count = 0
	for _ in value do
		count += 1
	end
	return count == #value
end

local function sortedKeys(value: { [unknown]: unknown }): { string }
	local keys: { string } = {}
	for key in value do
		table.insert(keys, tostring(key))
	end
	table.sort(keys, function(a, b)
		local aOrder = table.find(KEY_ORDER, a) or math.huge
		local bOrder = table.find(KEY_ORDER, b) or math.huge
		if aOrder ~= bOrder then
			return aOrder < bOrder
		end
		return a < b
	end)
	return keys
end

local renderValue: (value: unknown, depth: number) -> string

local function renderTable(value: { [unknown]: unknown }, depth: number): string
	if next(value) == nil then
		return "{}"
	end

	local list = isList(value)
	local items: { string } = {}
	local allPlain = true
	if list then
		for _, item in value :: { unknown } do
			allPlain = allPlain and typeof(item) ~= "table"
			table.insert(items, renderValue(item, depth + 1))
		end
	else
		for _, key in sortedKeys(value) do
			local item = (value :: { [string]: unknown })[key]
			allPlain = allPlain and typeof(item) ~= "table"
			table.insert(items, `{renderKey(key)} = {renderValue(item, depth + 1)}`)
		end
	end

	local inline = `\{ {table.concat(items, ", ")} \}`
	if allPlain and depth + #inline <= MAX_INLINE_WIDTH then
		return inline
	end

	local indent = string.rep("\t", depth + 1)
	local lines = { "{" }
	for _, item in items do
		table.insert(lines, `{indent}{item},`)
	end
	table.insert(lines, `{string.rep("\t", depth)}}`)
	return table.concat(lines, "\n")
end

function renderValue(value: unknown, depth: number): string
	if typeof(value) == "string" then
		return renderString(value)
	elseif typeof(value) == "table" then
		return renderTable(value :: { [unknown]: unknown }, depth)
	end
	return tostring(value)
end

local function renderLuauConfig(config: { [string]: unknown }): string
	-- The top-level table always gets a line per setting.
	local lines = { "return {" }
	for _, key in sortedKeys(config :: { [unknown]: unknown }) do
		table.insert(lines, `\t{renderKey(key)} = {renderValue(config[key], 1)},`)
	end
	table.insert(lines, "}")
	return table.concat(lines, "\n") .. "\n"
end

return renderLuauConfig
