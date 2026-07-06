--[[
	Given the list of files git reports as added between a base ref and HEAD,
	return just the ones that are unreleased change entries under `dir`.

	Kept as a pure function (mirroring `evaluateReleaseGate`) so the decision
	logic behind `check` is testable without shelling out to git. It applies the
	same "what counts as an entry" rules as `readUnreleasedChanges`: a markdown
	file inside the unreleased-changes directory, excluding the directory's
	`README.md`.
]]

local function normalizePath(value: string): string
	-- git reports POSIX-style, repo-relative paths. Strip a leading `./` and any
	-- trailing slashes so the directory config (e.g. `./.changes/`) and the diff
	-- output compare cleanly.
	local normalized = value:gsub("^%./", "")
	normalized = normalized:gsub("/+$", "")
	return normalized
end

local function isEntryFile(file: string, dir: string): boolean
	local normalizedFile = normalizePath(file)
	local normalizedDir = normalizePath(dir)

	if normalizedDir ~= "" then
		local prefix = normalizedDir .. "/"
		if normalizedFile:sub(1, #prefix) ~= prefix then
			return false
		end
	end

	if not normalizedFile:match("%.md$") then
		return false
	end

	local name = normalizedFile:match("[^/]+$") or normalizedFile
	if name:lower() == "readme.md" then
		return false
	end

	return true
end

local function detectAddedEntries(addedFiles: { string }, dir: string): { string }
	local entries: { string } = {}
	for _, file in addedFiles do
		if isEntryFile(file, dir) then
			table.insert(entries, file)
		end
	end
	return entries
end

return detectAddedEntries
