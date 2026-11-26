local REPLACEMENTS: { [string]: string } = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&apos;",
}

local function escapeXmlAttribute(value: string): string
	local escaped = value:gsub("[&<>\"']", REPLACEMENTS)
	return escaped
end

return escapeXmlAttribute
