local chomp = require("@root/chomp")
local splitLines = require("@root/release/splitLines")
local stripQuotes = require("@root/release/stripQuotes")

export type Frontmatter = {
	fields: { [string]: string },
	body: string,
}

local function parseFrontmatter(text: string, context: string): Frontmatter
	local lines = splitLines(text)

	local index = 1
	while index <= #lines and chomp(lines[index]) == "" do
		index += 1
	end
	assert(chomp(lines[index] or "") == "---", `{context} is missing its \`---\` frontmatter`)
	index += 1

	local fields: { [string]: string } = {}
	local closed = false
	while index <= #lines do
		local line = lines[index]
		index += 1
		if chomp(line) == "---" then
			closed = true
			break
		end
		local key, value = line:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
		if key ~= nil and value ~= nil then
			fields[key] = stripQuotes(value)
		end
	end
	assert(closed, `{context} frontmatter is not closed with \`---\``)

	local bodyLines = {}
	for j = index, #lines do
		table.insert(bodyLines, lines[j])
	end

	return {
		fields = fields,
		body = chomp(table.concat(bodyLines, "\n")),
	}
end

return parseFrontmatter
