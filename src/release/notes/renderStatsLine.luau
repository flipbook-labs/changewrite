local constants = require("@root/release/constants")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- A one-line count of the release's shape, such as "3 new · 2 fixed · 12 internal".
-- Kinds are counted outside collapsed categories, and each collapsed category
-- is counted as a whole, since its entries are summarized rather than read.
local function renderStatsLine(entries: { UnreleasedChange }, collapsed: { string }): string?
	local kindCounts: { [string]: number } = {}
	local categoryCounts: { [string]: number } = {}
	for _, entry in entries do
		if table.find(collapsed, entry.category) then
			categoryCounts[entry.category] = (categoryCounts[entry.category] or 0) + 1
		elseif entry.kind then
			kindCounts[entry.kind] = (kindCounts[entry.kind] or 0) + 1
		end
	end

	local parts: { string } = {}
	for _, kind in constants.CHANGE_KINDS do
		if kindCounts[kind] then
			table.insert(parts, `{kindCounts[kind]} {kind}`)
		end
	end
	for _, category in collapsed do
		if categoryCounts[category] then
			table.insert(parts, `{categoryCounts[category]} {category:lower()}`)
		end
	end

	if #parts == 0 then
		return nil
	end
	return table.concat(parts, " · ")
end

return renderStatsLine
