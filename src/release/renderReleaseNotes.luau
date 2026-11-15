local fs = require("@std/fs")

local extractReleaseSection = require("@root/release/extractReleaseSection")
local promoteHeadings = require("@root/release/promoteHeadings")

local CHANGELOG_FILE = "CHANGELOG.md"

-- In CHANGELOG.md a release's headings start at level 3, under the file's
-- title and the `## v<version>` heading. A GitHub release shows the version as
-- its own title, so its notes start at level 1.
local function renderReleaseNotes(tag: string): string
	return promoteHeadings(extractReleaseSection(fs.readFileToString(CHANGELOG_FILE), tag), 2)
end

return renderReleaseNotes
