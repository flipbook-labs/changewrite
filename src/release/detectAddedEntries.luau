--[[
	Filter the files git reports as added between a base ref and HEAD down to the
	ones that count as unreleased change entries under `dir`.

	What counts as an entry matches what `readUnreleasedChanges` consumes at
	release time: a markdown file directly inside the unreleased-changes
	directory, excluding the directory's `README.md`.
]]

local path = require("@std/path")

local function isEntryFile(file: string, dir: string): boolean
	local relative = path.relative(path.normalize(dir), path.normalize(file))

	-- `readUnreleasedChanges` lists the directory non-recursively, so only a
	-- direct child is ever consumed. A single path component is a direct child;
	-- more components (or a leading `..`) means the file is nested or outside the
	-- directory and would be silently dropped at release time.
	if #relative.parts ~= 1 then
		return false
	end

	local name = relative.parts[1]
	if path.extname(name) ~= ".md" then
		return false
	end

	return name:lower() ~= "readme.md"
end

local function detectAddedEntries(addedFiles: { string }, dir: string): { string }
	local entries: { string } = {}
	-- Callers union several git listings (committed, staged, untracked), so the
	-- same path can arrive more than once. Keep the first and drop repeats.
	local seen: { [string]: true } = {}
	for _, file in addedFiles do
		if isEntryFile(file, dir) and not seen[file] then
			seen[file] = true
			table.insert(entries, file)
		end
	end
	return entries
end

return detectAddedEntries
