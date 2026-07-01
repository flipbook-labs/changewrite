-- Strip trailing whitespace from a string. Command output almost always
-- arrives with a trailing newline, so this is the shared "chomp it off" helper
-- for when we want the bare value.
local function chomp(value: string): string
	return (value:gsub("%s+$", ""))
end

return chomp
