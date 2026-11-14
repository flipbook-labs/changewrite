local REPLACEMENTS: { [string]: string } = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&apos;",
}

local function escapeXmlAttribute(value: string): string
	return (value:gsub("[&<>\"']", REPLACEMENTS))
end

return escapeXmlAttribute
