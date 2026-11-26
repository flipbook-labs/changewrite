local planChips = require("@root/chips/planChips")

type PlannedChip = planChips.PlannedChip

--[[
	Compares the files `changewrite generate` would write with the ones on disk,
	and returns one line for each chip that's out of date. `drawn` maps each
	filename to the contents just drawn for it, and `readFile` returns a file's
	contents on disk, or nil when it's missing. Chips removed from
	changewrite.luau aren't reported, since their files stay for past releases.
]]
local function findStaleChips(
	planned: { PlannedChip },
	drawn: { [string]: string },
	readFile: (name: string) -> string?
): { string }
	local stale: { string } = {}
	for _, chip in planned do
		local missing: string? = nil
		local changed = false
		for _, file in { chip.files.light, chip.files.dark, chip.files.fallback } do
			local onDisk = readFile(file)
			if onDisk == nil then
				missing = missing or file
			elseif onDisk ~= drawn[file] then
				changed = true
			end
		end
		if missing then
			table.insert(stale, `{chip.key} is missing {missing}`)
		elseif changed then
			table.insert(stale, `{chip.key} changed in changewrite.luau`)
		end
	end
	return stale
end

return findStaleChips
