local chipLock = require("@root/chips/chipLock")
local planChips = require("@root/chips/planChips")

type ChipLock = chipLock.ChipLock
type PlannedChip = planChips.PlannedChip

-- Compares the chips the config describes with the lockfile and the files on
-- disk, and returns one line for each that's out of date. It compares each
-- chip's hash and text with the lockfile and checks that its files exist,
-- without redrawing anything, which keeps it fast enough for every `check` run.
local function findStaleChips(
	planned: { PlannedChip },
	lock: ChipLock?,
	fileExists: (name: string) -> boolean
): { string }
	if lock == nil then
		return { "The chip lockfile is missing" }
	end

	local stale: { string } = {}
	local expected: { [string]: true } = {}
	for _, chip in planned do
		expected[chip.key] = true
		local locked = lock[chip.key]
		if locked == nil then
			table.insert(stale, `{chip.key} has no chip yet`)
		elseif locked.hash ~= chip.hash or locked.text ~= chip.text then
			table.insert(stale, `{chip.key} changed in changewrite.toml`)
		else
			for _, file in { chip.files.light, chip.files.dark, chip.files.fallback } do
				if not fileExists(file) then
					table.insert(stale, `{chip.key} is missing {file}`)
				end
			end
		end
	end

	local removed: { string } = {}
	for key in lock do
		if not expected[key] then
			table.insert(removed, `{key} is no longer in changewrite.toml`)
		end
	end
	table.sort(removed)
	table.move(removed, 1, #removed, #stale + 1, stale)
	return stale
end

return findStaleChips
