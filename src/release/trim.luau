local function trim(value: string): string
	local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
	return trimmed
end

return trim
