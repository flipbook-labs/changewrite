local function splitLines(text: string): { string }
	local lines = string.split(text, "\n")
	for index, line in lines do
		local stripped = line:gsub("\r$", "")
		lines[index] = stripped
	end
	return lines
end

return splitLines
