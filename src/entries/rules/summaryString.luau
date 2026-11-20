local path = require("@std/path")
local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")

local evaluateLiteral = require("../evaluateLiteral")
local findEntryTable = require("../findEntryTable")
local getEntryField = require("../getEntryField")
local types = require("../types")

local NAME = "changewrite_summary_string"

-- The summary renders as a single bullet, so it has to be one line of plain
-- text. A block string can wrap onto a second line, so the summary has to be
-- quoted, and a quoted string can still hold a `\n` escape, so the decoded
-- value is checked too.
local function getProblem(value: syntax.CstExpr): string?
	local constant = utils.isExprConstantString(value)
	if utils.isExprInterpString(value) or (constant and constant.quoteStyle == "interp") then
		return "Write the summary as a plain quoted string, not an interpolated one."
	elseif not constant then
		return "Write the summary as a quoted string."
	elseif constant.quoteStyle == "block" then
		return "Write the summary as a quoted string on one line, not a block string. Put any details in `description`."
	end

	local summary = evaluateLiteral(value)
	if typeof(summary) == "string" and summary:find("\n") then
		return "Keep the summary on one line. Put any details in `description`."
	end
	return nil
end

local function lint(cst: syntax.CstStatBlock, sourcepath: path.Path?): { types.LintViolation }
	local entry = findEntryTable(cst)
	local field = if entry then getEntryField(entry, "summary") else nil
	if not field then
		return {}
	end
	local problem = getProblem(field.value)
	if not problem then
		return {}
	end

	return {
		{
			lintname = NAME,
			location = field.value.location,
			message = problem,
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
