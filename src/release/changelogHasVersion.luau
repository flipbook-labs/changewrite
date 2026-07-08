-- Whether the changelog already documents `version` as a released section.
-- `prepare-pr` writes a `## v<version>` heading when it folds in the pending
-- changes, so this is the fingerprint that a release was actually prepared for
-- the current version -- as opposed to a pristine repo that merely happens to
-- carry an untagged version in its manifest.
local function changelogHasVersion(changelog: string, version: string): boolean
	local plain = version:gsub("^v", "")
	local heading = `## v{plain}`

	for line in changelog:gmatch("[^\n]+") do
		local trimmed = line:match("^%s*(.-)%s*$") or line
		-- Match the bare heading or one carrying a trailing suffix (e.g. a date),
		-- but not a longer version that merely shares this one as a prefix.
		if trimmed == heading or trimmed:sub(1, #heading + 1) == heading .. " " then
			return true
		end
	end

	return false
end

return changelogHasVersion
