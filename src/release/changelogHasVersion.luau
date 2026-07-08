-- Whether the changelog already documents `version` as a released section.
-- `prepare-pr` writes a `v<version>` heading when it folds in the pending
-- changes, so this is the fingerprint that a release was actually prepared for
-- the current version. A pristine repo that merely carries an untagged version
-- in its manifest has no such heading.
local function changelogHasVersion(changelog: string, version: string): boolean
	if changelog == "" then
		return false
	end

	local plain = version:gsub("^v", "")
	-- Escape any Lua pattern magic (the dots in a version) so they match literally.
	local escaped = plain:gsub("(%W)", "%%%1")

	-- Matches a markdown heading line for this version at any depth: one or more
	-- `#`, whitespace, then `v<version>`, e.g. `# v1.2.3` or `## v1.2.3`. The
	-- captured trailing text lets a heading with a suffix (like a date) match
	-- while stopping a shorter query from matching a longer version.
	local pattern = `^#+%s+v{escaped}(.*)$`

	for line in changelog:gmatch("[^\n]+") do
		local trimmed = line:match("^%s*(.-)%s*$") or line
		local rest = trimmed:match(pattern)
		if rest and (rest == "" or rest:match("^%s")) then
			return true
		end
	end

	return false
end

return changelogHasVersion
