local fs = require("@std/fs")

local extractReleaseSection = require("@root/release/extractReleaseSection")

local CHANGELOG_FILE = "CHANGELOG.md"

-- Render the Markdown notes for a single release: the body that goes on the
-- GitHub release, and the preview shown in the publish PR. Both are sliced out
-- of the version's section in CHANGELOG.md, which `prepare-pr` has already
-- assembled from the change partials — so the PR preview and the drafted release
-- can't drift, and the notes don't depend on commit history.
local function renderReleaseNotes(tag: string): string
	return extractReleaseSection(fs.readFileToString(CHANGELOG_FILE), tag)
end

return renderReleaseNotes
