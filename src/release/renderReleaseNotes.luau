local fs = require("@std/fs")

local extractReleaseSection = require("@root/release/extractReleaseSection")

local CHANGELOG_FILE = "CHANGELOG.md"

local function renderReleaseNotes(tag: string): string
	return extractReleaseSection(fs.readFileToString(CHANGELOG_FILE), tag)
end

return renderReleaseNotes
