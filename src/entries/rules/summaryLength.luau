local path = require("@std/path")
local syntax = require("@std/syntax")

local evaluateLiteral = require("../evaluateLiteral")
local findEntryTable = require("../findEntryTable")
local getEntryField = require("../getEntryField")
local types = require("../types")

local NAME = "changewrite_summary_length"
-- A summary is one line in a long list, and past about 140 characters it reads
-- as a paragraph a skimming reader skips.
local DEFAULT_MAX_LENGTH = 140

local function lint(
	cst: syntax.CstStatBlock,
	sourcepath: path.Path?,
	context: types.RuleContext
): { types.LintViolation }
	local entry = findEntryTable(cst)
	local field = if entry then getEntryField(entry, "summary") else nil
	if not field then
		return {}
	end
	local summary = evaluateLiteral(field.value)
	if typeof(summary) ~= "string" then
		return {}
	end

	local option = context.options.max_length
	local maxLength = if typeof(option) == "number" then option else DEFAULT_MAX_LENGTH
	-- `utf8.len` returns nil for invalid UTF-8, which falls back to bytes.
	local length = utf8.len(summary) or #summary
	if length <= maxLength then
		return {}
	end

	return {
		{
			lintname = NAME,
			location = field.value.location,
			message = `The summary is {length} characters, over the limit of {maxLength}. Keep it to one short sentence and put any details in \`description\`.`,
			severity = "error",
			sourcepath = sourcepath,
		},
	}
end

local rule: types.LintRule = {
	name = NAME,
	lint = lint,
}

return table.freeze(rule)
