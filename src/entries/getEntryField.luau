local syntax = require("@std/syntax")

local function getEntryField(entry: syntax.CstExprTable, name: string): syntax.CstTableExprRecordItem?
	for _, item in entry.entries do
		if item.kind == "record" and item.key.text == name then
			return item
		end
	end
	return nil
end

return getEntryField
