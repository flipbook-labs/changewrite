local constants = require("@root/release/constants")

--[[
	Keeps the focused items and up to `neighbors` items on each side of each
	one, and replaces every run of items it leaves out with one
	`constants.EXCERPT_CUT` line, so the excerpt shows where it was cut. Returns
	nil when no item is focused.
]]
local function excerptItems(items: { string }, isFocused: { boolean }, neighbors: number): { string }?
	local isKept: { [number]: true } = {}
	local hasFocus = false
	for index = 1, #items do
		if isFocused[index] then
			hasFocus = true
			for kept = math.max(1, index - neighbors), math.min(#items, index + neighbors) do
				isKept[kept] = true
			end
		end
	end
	if not hasFocus then
		return nil
	end

	local excerpt: { string } = {}
	local isCut = false
	for index, item in items do
		if isKept[index] then
			if isCut then
				table.insert(excerpt, constants.EXCERPT_CUT)
				isCut = false
			end
			table.insert(excerpt, item)
		else
			isCut = true
		end
	end
	if isCut then
		table.insert(excerpt, constants.EXCERPT_CUT)
	end
	return excerpt
end

return excerptItems
