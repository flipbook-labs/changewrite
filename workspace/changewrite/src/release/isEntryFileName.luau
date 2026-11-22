local function isEntryFileName(name: string): boolean
	return name:match("%.luau$") ~= nil
end

return isEntryFileName
