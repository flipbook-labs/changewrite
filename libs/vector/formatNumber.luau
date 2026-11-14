-- Writes a coordinate with at most two decimals and no trailing zeros, so the
-- same geometry always produces the same SVG text.
local function formatNumber(value: number): string
	local text = string.format("%.2f", value)
	text = text:gsub("0+$", ""):gsub("%.$", "")
	if text == "-0" then
		return "0"
	end
	return text
end

return formatNumber
