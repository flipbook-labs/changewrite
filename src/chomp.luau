local function chomp(value: string): string
	return (value:gsub("%s+$", ""))
end

return chomp
