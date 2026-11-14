local constants = require("@root/release/constants")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- Orders entries by kind in the configured kind order, with entries that have
-- no kind last. Entries of the same kind keep their original order.
local function sortByKind(entries: { UnreleasedChange }): { UnreleasedChange }
	local function rank(entry: UnreleasedChange): number
		if entry.kind == nil then
			return #constants.CHANGE_KINDS + 1
		end
		return table.find(constants.CHANGE_KINDS, entry.kind) or #constants.CHANGE_KINDS + 1
	end

	local positions: { [UnreleasedChange]: number } = {}
	for index, entry in entries do
		positions[entry] = index
	end

	local sorted = table.clone(entries)
	table.sort(sorted, function(a: UnreleasedChange, b: UnreleasedChange)
		local rankA, rankB = rank(a), rank(b)
		if rankA ~= rankB then
			return rankA < rankB
		end
		return positions[a] < positions[b]
	end)
	return sorted
end

return sortByKind
