-- Reads a `#rrggbb` color into channels from 0 to 1.
local function parseHexColor(color: string): (number, number, number)
	local rText, gText, bText = color:match("^#(%x%x)(%x%x)(%x%x)$")
	local r, g, b = tonumber(rText, 16), tonumber(gText, 16), tonumber(bText, 16)
	assert(r and g and b, `Expected a #rrggbb color, got "{color}"`)
	return r / 255, g / 255, b / 255
end

return parseHexColor
