local chomp = require("@root/chomp")
local parseFrontmatter = require("@root/release/parseFrontmatter")

export type ParsedReleaseSummary = {
	name: string?,
	tldr: string,
}

local function parseReleaseSummary(text: string): ParsedReleaseSummary
	-- Frontmatter is only needed to set a name, so a file holding just the TL;DR
	-- is valid on its own.
	if not text:match("^%s*%-%-%-") then
		local tldr = chomp(text)
		assert(tldr ~= "", "Release summary is empty")
		return {
			name = nil,
			tldr = tldr,
		}
	end

	local frontmatter = parseFrontmatter(text, "Release summary")
	assert(frontmatter.body ~= "", "Release summary has no TL;DR below its frontmatter")

	local name = frontmatter.fields.name
	if name == "" then
		name = nil
	end

	return {
		name = name,
		tldr = frontmatter.body,
	}
end

return parseReleaseSummary
