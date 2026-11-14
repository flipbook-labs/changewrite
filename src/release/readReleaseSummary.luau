local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local parseReleaseSummary = require("@root/release/parseReleaseSummary")
local types = require("@root/release/types")

type ReleaseSummary = types.ReleaseSummary

-- Matches the summary's filename in any letter case, the same rule
-- `readUnreleasedChanges` uses to leave it out of the entries, so a file can't
-- slip past both.
local function readReleaseSummary(): ReleaseSummary?
	local dir = getUnreleasedChangesDir()
	if not fs.exists(dir) then
		return nil
	end

	for _, entry in fs.listDirectory(dir) do
		if entry.type ~= "file" or entry.name:lower() ~= constants.RELEASE_SUMMARY_FILE then
			continue
		end

		local file = path.join(dir, entry.name)
		local success, parsed = pcall(parseReleaseSummary, fs.readFileToString(file))
		assert(success, `{file}: {parsed}`)
		return {
			file = file,
			name = parsed.name,
			tldr = parsed.tldr,
		}
	end
	return nil
end

return readReleaseSummary
