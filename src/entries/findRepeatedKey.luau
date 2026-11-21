local parser = require("@std/syntax/parser")
local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")
local visitor = require("@std/syntax/visitor")

export type RepeatedKey = {
	name: string,
	line: number,
}

local function getKeyName(item: syntax.CstTableExprItem): string?
	if item.kind == "record" then
		return item.key.text
	elseif item.kind == "general" then
		local key = utils.isExprConstantString(item.key)
		return if key then key.value.text else nil
	end
	return nil
end

-- Luau keeps only the last value when a table constructor names the same key
-- twice, so an entry that sets `summary` twice would silently lose the first
-- one. This finds a key that some table constructor in `source` names twice,
-- as `name =` or `["name"] =`, along with the line of the second one. It
-- returns nil when there's none. `source` must already be valid Luau.
local function findRepeatedKey(source: string): RepeatedKey?
	local repeated: RepeatedKey? = nil

	local finder = visitor.create()
	finder.visitExprTable = function(node: syntax.CstExprTable)
		local seen: { [string]: true } = {}
		for _, item in node.entries do
			local name = getKeyName(item)
			if name == nil then
				continue
			end
			if seen[name] and repeated == nil then
				repeated = { name = name, line = item.location.beginLine }
			end
			seen[name] = true
		end
		-- Returning false stops the visitor from descending into this table's
		-- values, since one repeat is enough to report.
		return repeated == nil
	end

	visitor.visitBlock(parser.parseBlock(source), finder)
	return repeated
end

return findRepeatedKey
