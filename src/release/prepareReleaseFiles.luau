local fs = require("@std/fs")

local readChangePartials = require("@root/release/readChangePartials")
local removeChangePartials = require("@root/release/removeChangePartials")
local renderChangelogSection = require("@root/release/renderChangelogSection")
local writeVersion = require("@root/release/writeVersion")

type ChangelogEntry = readChangePartials.ChangelogEntry

local CHANGELOG_FILE = "CHANGELOG.md"
local DEFAULT_HEADER = "# Changelog\n\nAll notable changes to this project will be documented in this file."

-- Insert a freshly rendered section directly below the changelog's header block
-- and above the previous releases, keeping two blank lines between blocks to
-- match the existing layout. The changelog is prepend-only now: once a release's
-- partials are deleted, history can't be regenerated, so we never rewrite the
-- entries already on disk.
local function prependSection(changelog: string, section: string): string
	local header = changelog
	local releases = ""

	if changelog:sub(1, 3) == "## " then
		header = ""
		releases = changelog
	else
		local headingStart = changelog:find("\n## ")
		if headingStart then
			header = changelog:sub(1, headingStart - 1)
			releases = changelog:sub(headingStart + 1)
		end
	end

	header = (header:gsub("%s+$", ""))
	releases = (releases:gsub("^%s+", ""):gsub("%s+$", ""))

	local parts: { string } = {}
	if header ~= "" then
		table.insert(parts, header)
	end
	table.insert(parts, section)
	if releases ~= "" then
		table.insert(parts, releases)
	end
	return table.concat(parts, "\n\n\n") .. "\n"
end

-- Write a version across the configured source + mirrors, fold the pending
-- change partials into CHANGELOG.md under that version, and delete the consumed
-- partials. Returns every file that changed (version files, the changelog, and
-- the removed partials) so the caller can stage them for the publish PR. Shared
-- by `prepare-pr` and `bump`, which differ only in how they pick the version and
-- gather partials.
local function prepareReleaseFiles(nextVersion: string, partials: { ChangelogEntry }): { string }
	local changedFiles = writeVersion(nextVersion)

	-- With no partials there is nothing to fold into the changelog (the `bump`
	-- escape hatch can reach this), so only the version moves. Writing an empty
	-- section here would leave a headless `## v{version}` heading in CHANGELOG.md.
	if #partials == 0 then
		return changedFiles
	end

	local section = renderChangelogSection(nextVersion, partials)
	local existing = if fs.exists(CHANGELOG_FILE) then fs.readFileToString(CHANGELOG_FILE) else DEFAULT_HEADER
	fs.writeStringToFile(CHANGELOG_FILE, prependSection(existing, section))
	table.insert(changedFiles, CHANGELOG_FILE)

	local consumed: { string } = {}
	for _, partial in partials do
		table.insert(consumed, partial.file)
	end
	removeChangePartials(consumed)
	for _, file in consumed do
		table.insert(changedFiles, file)
	end

	return changedFiles
end

return prepareReleaseFiles
