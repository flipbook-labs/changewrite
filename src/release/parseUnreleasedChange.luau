local parser = require("@std/syntax/parser")
local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")

local chomp = require("@root/chomp")
local constants = require("@root/release/constants")
local evaluateLiteral = require("@root/entries/evaluateLiteral")
local findEntryTable = require("@root/entries/findEntryTable")
local parseVersionComponent = require("@root/semver/parseVersionComponent")
local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag
type ParsedUnreleasedChange = types.ParsedUnreleasedChange

local DEFAULT_CATEGORY = "Changes"

local FIELDS = {
	"bump",
	"category",
	"kind",
	"flags",
	"highlight",
	"pr",
	"summary",
	"description",
}

local function readString(name: string, value: syntax.CstExpr, line: number): string
	local text = evaluateLiteral(value)
	assert(typeof(text) == "string", `line {line}: Unreleased change {name} must be a string`)
	return text
end

local function readFlags(value: syntax.CstExpr, line: number): { ChangeFlag }
	local list = utils.isExprTable(value)
	assert(list, `line {line}: Unreleased change flags must be a list, such as \{ "breaking" \}`)

	local flags: { ChangeFlag } = {}
	for _, item in list.entries do
		local flag = if item.kind == "list" then evaluateLiteral(item.value) else nil
		assert(typeof(flag) == "string", `line {line}: Unreleased change flags must be a list of strings`)
		assert(
			table.find(constants.CHANGE_FLAGS, flag) ~= nil,
			`line {line}: Unreleased change flag "{flag}" is not supported. Expected any of: {table.concat(
				constants.CHANGE_FLAGS,
				", "
			)}`
		)
		if table.find(flags, flag :: ChangeFlag) == nil then
			table.insert(flags, flag :: ChangeFlag)
		end
	end
	return flags
end

-- An entry is a Luau file that returns a table of its fields. Changewrite
-- reads the table from the syntax tree instead of running the file, so an
-- entry can only hold literal values.
--
-- `categories` and `kinds` are the lists `changewrite.toml` configures. Once a
-- repo configures either list, every entry has to pick a value from it, so no
-- entry renders without a heading or a chip. Without a `categories` list, an
-- entry may leave out its category and lands under Changes. A repo that
-- configures no kinds can't use the field.
local function parseUnreleasedChange(
	source: string,
	categories: { string }?,
	kinds: { string }?
): ParsedUnreleasedChange
	local parsed, block = pcall(parser.parseBlock, source)
	assert(parsed, `Unreleased change is not valid Luau: {block}`)
	local entry = findEntryTable(block)
	assert(entry, "Unreleased change must return a table of its fields")

	local strings: { [string]: string } = {}
	local lines: { [string]: number } = {}
	local flags: { ChangeFlag } = {}
	local pr: number? = nil
	for _, item in entry.entries do
		local line = item.location.beginLine
		if item.kind ~= "record" then
			error(`line {line}: Unreleased change fields must be written as \`name = value\``, 0)
		end
		local name = item.key.text
		assert(
			table.find(FIELDS, name) ~= nil,
			`line {line}: Unreleased change has an unknown field "{name}". Expected any of: {table.concat(FIELDS, ", ")}`
		)
		assert(lines[name] == nil, `line {line}: Unreleased change sets {name} more than once`)
		lines[name] = line

		if name == "flags" then
			flags = readFlags(item.value, line)
		elseif name == "pr" then
			local number = evaluateLiteral(item.value)
			assert(
				typeof(number) == "number" and number >= 1 and number % 1 == 0,
				`line {line}: Unreleased change pr must be a pull request number`
			)
			pr = number
		else
			strings[name] = readString(name, item.value, line)
		end
	end

	local summary = chomp(strings.summary or "")
	assert(summary ~= "", "Unreleased change has no summary")

	local bump = parseVersionComponent(strings.bump)
	local category = strings.category
	if categories then
		assert(category, `Unreleased change has no category. Expected one of: {table.concat(categories, ", ")}`)
		assert(
			table.find(categories, category) ~= nil,
			`line {lines.category}: Unreleased change category "{category}" is not configured. Expected one of: {table.concat(
				categories,
				", "
			)}`
		)
	end

	local kind = strings.kind
	local configuredKinds = kinds or {}
	if kind == nil then
		assert(
			#configuredKinds == 0,
			`Unreleased change has no kind. Expected one of: {table.concat(configuredKinds, ", ")}`
		)
	else
		assert(
			table.find(configuredKinds, kind) ~= nil,
			if #configuredKinds == 0
				then `line {lines.kind}: Unreleased change kind "{kind}" is not configured. Add a [kind.{kind}] table to changewrite.toml`
				else `line {lines.kind}: Unreleased change kind "{kind}" is not configured. Expected one of: {table.concat(
					configuredKinds,
					", "
				)}`
		)
	end

	local highlight = strings.highlight
	if highlight == "" then
		highlight = nil
	end

	local description = chomp(strings.description or "")
	local body = if description == "" then summary else `{summary}\n\n{description}`

	return {
		bump = bump,
		category = category or DEFAULT_CATEGORY,
		body = body,
		kind = kind,
		flags = flags,
		highlight = highlight,
		pr = pr,
	}
end

return parseUnreleasedChange
