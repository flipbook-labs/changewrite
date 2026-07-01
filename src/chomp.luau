local function chomp(value: string): string
	local chomped = value:gsub("%s+$", "")
	return chomped
end

return chomp
