local chomp = require("@root/chomp")
local parseFrontmatter = require("@root/release/parseFrontmatter")
local stripQuotes = require("@root/release/stripQuotes")

local STRING_FIELDS = {
	"bump",
	"category",
	"kind",
	"highlight",
}

local function quote(value: string): string
	local escaped = value:gsub("\\", "\\\\"):gsub('"', '\\"')
	return `"{escaped}"`
end

-- Wraps the text in `[[ ]]`, adding `=` signs, as in `[=[ ]=]`, until the
-- text can't contain the closing delimiter and end the string early. Luau
-- drops a newline right after the opening delimiter, so the text starts on
-- its own line without gaining a blank one.
local function renderBlockString(text: string): string
	local level = 0
	while text:find(`]{string.rep("=", level)}]`, 1, true) do
		level += 1
	end
	local equals = string.rep("=", level)
	return `[{equals}[\n{text}\n]{equals}]`
end

local function parseFlags(value: string): { string }
	local flags = {}
	local list = value:match("^%[(.*)%]$") or value
	for _, rawFlag in list:split(",") do
		local flag = stripQuotes(chomp(rawFlag))
		if flag ~= "" then
			table.insert(flags, flag)
		end
	end
	return flags
end

-- Converts a Markdown entry to the Luau format. The first paragraph of the
-- body becomes the summary, joined onto one line, and the rest becomes the
-- description. A wrapped paragraph renders as one line in Markdown, so joining
-- it doesn't change the summary's text.
local function convertMarkdownEntry(text: string): string
	local frontmatter = parseFrontmatter(text, "Markdown entry")
	local fields = frontmatter.fields
	for name in fields do
		assert(
			table.find(STRING_FIELDS, name) ~= nil or name == "flags" or name == "pr",
			`Markdown entry has an unknown field "{name}". Remove it and run again.`
		)
	end

	local body = frontmatter.body
	assert(body ~= "", "Markdown entry has no body")
	local summaryLines, description = body:match("^(.-)\n%s*\n(.*)$")
	if not summaryLines then
		summaryLines = body
	end
	local summary = chomp((summaryLines :: string):gsub("%s*\n%s*", " "))

	local lines = {
		"return {",
	}
	for _, name in STRING_FIELDS do
		local value = fields[name]
		if value and value ~= "" then
			table.insert(lines, `\t{name} = {quote(value)},`)
		end
	end
	local flags = parseFlags(fields.flags or "")
	if #flags > 0 then
		local quoted = {}
		for _, flag in flags do
			table.insert(quoted, quote(flag))
		end
		table.insert(lines, `\tflags = \{ {table.concat(quoted, ", ")} \},`)
	end
	if fields.pr and fields.pr ~= "" then
		local digits = fields.pr:match("^#?(%d+)$")
		assert(digits, `Markdown entry pr "{fields.pr}" must be a pull request number`)
		table.insert(lines, `\tpr = {digits},`)
	end
	table.insert(lines, `\tsummary = {quote(summary)},`)
	if description and chomp(description) ~= "" then
		table.insert(lines, `\tdescription = {renderBlockString(chomp(description))},`)
	end
	table.insert(lines, "}")
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

return convertMarkdownEntry
