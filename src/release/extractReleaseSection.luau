local splitLines = require("@root/release/splitLines")
local trim = require("@root/release/trim")

local function extractReleaseSection(changelog: string, version: string): string
	local plain = version:gsub("^v", "")
	local target = `## v{plain}`

	local lines = splitLines(changelog)

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
