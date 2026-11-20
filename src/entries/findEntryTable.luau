local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")

local function unwrapExpr(expr: syntax.CstExpr): syntax.CstExpr
	local current = expr
	while true do
		local group = utils.isExprGroup(current)
		local cast = utils.isExprTypeAssertion(current)
		if group then
			current = group.expression
		elseif cast then
			current = cast.operand
		else
			return current
		end
	end
end

-- Finds the value a local was declared with, so an entry can annotate a local
-- with its type and return the local.
local function findLocalValue(block: syntax.CstStatBlock, target: syntax.CstLocal): syntax.CstExpr?
	for _, statement in block.statements do
		local declaration = utils.isStatLocal(statement)
		if not declaration then
			continue
		end
		for index, variable in declaration.variables do
			if variable == target then
				return declaration.values[index]
			end
		end
	end
	return nil
end

-- Returns the table an entry file returns, either directly or through a local.
-- A file that returns anything else isn't an entry, so this returns nil.
local function findEntryTable(block: syntax.CstStatBlock): syntax.CstExprTable?
	local last = block.statements[#block.statements]
	local returnStatement = if last then utils.isStatReturn(last) else nil
	if not returnStatement or #returnStatement.expressions ~= 1 then
		return nil
	end

	local value = unwrapExpr(returnStatement.expressions[1])
	local localRef = utils.isExprLocal(value)
	if localRef then
		local declared = findLocalValue(block, localRef["local"])
		if not declared then
			return nil
		end
		value = unwrapExpr(declared)
	end
	return utils.isExprTable(value)
end

return findEntryTable
