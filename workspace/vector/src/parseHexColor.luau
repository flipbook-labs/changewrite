-- Reads a `#rrggbb` color into channels from 0 to 1.
local function parseHexColor(color: string): (number, number, number)
	local r, g, b = color:match("^#(%x%x)(%x%x)(%x%x)$")
	assert(r and g and b, `Expected a #rrggbb color, got "{color}"`)
	return (tonumber(r, 16) :: number) / 255, (tonumber(g, 16) :: number) / 255, (tonumber(b, 16) :: number) / 255
end

return parseHexColor
