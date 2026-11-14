local chomp = require("@root/chomp")

export type ParsedReleaseSummary = {
	tldr: string,
}

-- The whole file is the TL;DR, written as plain Markdown.
local function parseReleaseSummary(text: string): ParsedReleaseSummary
	local tldr = chomp(text)
	assert(tldr ~= "", "Release summary is empty")
	return {
		tldr = tldr,
	}
end

return parseReleaseSummary
