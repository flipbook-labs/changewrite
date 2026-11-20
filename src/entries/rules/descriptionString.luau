local path = require("@std/path")
local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")

local findEntryTable = require("../findEntryTable")
local getEntryField = require("../getEntryField")
local types = require("../types")

local NAME = "changewrite_description_string"

local function lint(cst: syntax.CstStatBlock, sourcepath: path.Path?): { types.LintViolation }
	local entry = findEntryTable(cst)
	local field = if entry then getEntryField(entry, "description") else nil
	if not field then
		return {}
	end
	local constant = utils.isExprConstantString(field.value)
	if constant and constant.quoteStyle == "block" then
		return {}
	end

	return {
		{
			lintname = NAME,
			location = field.value.location,
			message = "Write the description as a block string, `[[ ... ]]`, so it can span lines.",
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
