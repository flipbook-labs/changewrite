--[[
	Given the list of files git reports as added between a base ref and HEAD,
	return just the ones that are unreleased change entries under `dir`.

	Kept as a pure function (mirroring `evaluateReleaseGate`) so the decision
	logic behind `check` is testable without shelling out to git. It applies the
	same "what counts as an entry" rules as `readUnreleasedChanges`: a markdown
	file directly inside the unreleased-changes directory (not a subdirectory),
	excluding the directory's `README.md`.
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

	local name = normalizedFile
	if normalizedDir ~= "" then
		local prefix = normalizedDir .. "/"
		if normalizedFile:sub(1, #prefix) ~= prefix then
			return false
		end
		name = normalizedFile:sub(#prefix + 1)
	end

	-- `readUnreleasedChanges` lists the directory non-recursively, so only a file
	-- sitting directly in it is ever consumed. A nested path like
	-- `.changes/subdir/fix.md` would pass a plain prefix check here but be
	-- silently skipped at release time, so reject anything below the top level.
	if name == "" or name:find("/") then
		return false
	end

	if not name:match("%.md$") then
		return false
	end

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
