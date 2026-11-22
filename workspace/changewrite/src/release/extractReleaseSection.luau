local chomp = require("@root/chomp")
local mapOutsideFences = require("@root/release/mapOutsideFences")
local splitLines = require("@root/release/splitLines")

-- Stands in for a release heading while the section is cut out. A changelog
-- never contains a NUL character, so it can't collide with a real line.
local RELEASE_HEADING_MARKER = "\0"

local function extractReleaseSection(changelog: string, version: string): string
	local plain = version:gsub("^v", "")
	local target = `## v{plain}`

	local lines = splitLines(changelog)

	local start: number? = nil
	for index, line in lines do
		if chomp(line) == target then
			start = index + 1
			break
		end
	end
	assert(start, `Could not find a "{target}" section in CHANGELOG.md`)

	-- Only another release heading ends the section. Changewrite writes every
	-- release as `## v<version>`, so any other `## ` line stays part of the
	-- notes. A release heading inside fenced code, such as an entry's
	-- description showing the changelog format, stays part of them too.
	local rest = table.concat(lines, "\n", start)
	local marked = mapOutsideFences(rest, function(line)
		return if line:match("^## v%d") then RELEASE_HEADING_MARKER else line
	end)

	local body: { string } = {}
	for _, line in splitLines(marked) do
		if line == RELEASE_HEADING_MARKER then
			break
		end
		table.insert(body, line)
	end

	return chomp(table.concat(body, "\n"))
end

return extractReleaseSection
