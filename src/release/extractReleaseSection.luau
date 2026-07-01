local function trim(value: string): string
	local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
	return trimmed
end

-- Slice a single version's notes out of a rendered CHANGELOG.md: everything
-- under its `## v{version}` heading up to the next `## ` heading (or the end of
-- the file), with the heading itself dropped since the GitHub release already
-- shows the tag as its title. Pure, so it can be unit tested against a literal
-- changelog string.
local function extractReleaseSection(changelog: string, version: string): string
	local target = `## v{(version:gsub("^v", ""))}`

	local lines: { string } = {}
	for line in (changelog .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, (line:gsub("\r$", "")))
	end

	local start: number? = nil
	for index, line in lines do
		if trim(line) == target then
			start = index + 1
			break
		end
	end
	assert(start, `Could not find a "{target}" section in CHANGELOG.md`)

	local body: { string } = {}
	for index = start, #lines do
		if lines[index]:match("^## ") then
			break
		end
		table.insert(body, lines[index])
	end

	return trim(table.concat(body, "\n"))
end

return extractReleaseSection
