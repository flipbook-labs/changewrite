local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- Groups a category's entries by kind, in alphabetical order, so changes to the
-- same part of the product sit together. Entries without a kind come last, and
-- entries of the same kind keep their original order.
local function sortByKind(entries: { UnreleasedChange }): { UnreleasedChange }
	local positions: { [UnreleasedChange]: number } = {}
	for index, entry in entries do
		positions[entry] = index
	end

	local sorted = table.clone(entries)
	table.sort(sorted, function(a: UnreleasedChange, b: UnreleasedChange)
		if a.kind ~= b.kind then
			if a.kind == nil or b.kind == nil then
				return b.kind == nil
			end
			return a.kind < b.kind
		end
		return positions[a] < positions[b]
	end)
	return sorted
end

return sortByKind
