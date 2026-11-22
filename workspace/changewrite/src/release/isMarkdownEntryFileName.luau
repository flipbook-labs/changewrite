local constants = require("@root/release/constants")

-- A Markdown file in the unreleased-changes directory, other than the folder's
-- `README.md` and the release summary (`release.md`), is a Markdown entry,
-- which `changewrite check --fix` converts to Luau.
local function isMarkdownEntryFileName(name: string): boolean
	local lowerName = name:lower()
	return lowerName:match("%.md$") ~= nil and lowerName ~= "readme.md" and lowerName ~= constants.RELEASE_SUMMARY_FILE
end

return isMarkdownEntryFileName
