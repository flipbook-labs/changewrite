local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- Puts entries in the order they merged, oldest first, using each entry's time
-- from `addedAt`. An entry without a time hasn't been committed yet, so it's
-- newer than the rest and goes last. Entries with the same time keep their
-- original order.
local function sortByAddedAt(
	entries: { UnreleasedChange },
	addedAt: { [UnreleasedChange]: number }
): { UnreleasedChange }
	local positions: { [UnreleasedChange]: number } = {}
	for index, entry in entries do
		positions[entry] = index
	end

	local sorted = table.clone(entries)
	table.sort(sorted, function(a: UnreleasedChange, b: UnreleasedChange)
		local aTime, bTime = addedAt[a], addedAt[b]
		if aTime ~= bTime then
			if aTime == nil or bTime == nil then
				return bTime == nil
			end
			return aTime < bTime
		end
		return positions[a] < positions[b]
	end)
	return sorted
end

return sortByAddedAt
