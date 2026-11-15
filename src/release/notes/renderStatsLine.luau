local isBreaking = require("@root/release/notes/isBreaking")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- A one-line count of the release's shape, such as "Breaking 1 · Features 3 ·
-- Internal 12". The name comes first so a count of one never needs a singular
-- form of a category's name. Breaking entries are counted on their own, since
-- they're listed apart from their categories.
local function renderStatsLine(entries: { UnreleasedChange }, categories: { string }): string?
	local breakingCount = 0
	local categoryCounts: { [string]: number } = {}
	for _, entry in entries do
		if isBreaking(entry) then
			breakingCount += 1
		else
			categoryCounts[entry.category] = (categoryCounts[entry.category] or 0) + 1
		end
	end

	local parts: { string } = {}
	if breakingCount > 0 then
		table.insert(parts, `Breaking {breakingCount}`)
	end
	for _, category in categories do
		if categoryCounts[category] then
			table.insert(parts, `{category} {categoryCounts[category]}`)
		end
	end

	if #parts == 0 then
		return nil
	end
	return table.concat(parts, " · ")
end

return renderStatsLine
