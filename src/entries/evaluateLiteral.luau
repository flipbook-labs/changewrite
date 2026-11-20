local luau = require("@std/luau")
local printer = require("@std/syntax/printer")
local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")

-- Changewrite reads an entry's values without running the entry file. This
-- returns the value of one string or number literal, or nil for any other
-- expression. It compiles just that literal and runs it with an empty
-- environment, so Luau decodes escapes and block strings exactly as it would
-- at runtime, and no other code from the entry ever runs.
local function evaluateLiteral(expr: syntax.CstExpr): (string | number)?
	if not utils.isExprConstantString(expr) and not utils.isExprConstantNumber(expr) then
		return nil
	end
	local chunk = luau.load(luau.compile(`return {printer.printNode(expr)}`), "literal", {})
	return chunk()
end

return evaluateLiteral
