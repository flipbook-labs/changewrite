local chomp = require("@root/chomp")
local parseVersionComponent = require("@root/release/parseVersionComponent")
local splitLines = require("@root/release/splitLines")
local stripQuotes = require("@root/release/stripQuotes")
local types = require("@root/release/types")

type ParsedUnreleasedChange = types.ParsedUnreleasedChange

local DEFAULT_CATEGORY = "Changes"

local function parseUnreleasedChange(text: string): ParsedUnreleasedChange
	local lines = splitLines(text)

	local index = 1
	while index <= #lines and chomp(lines[index]) == "" do
		index += 1
	end
	assert(chomp(lines[index] or "") == "---", "Unreleased change is missing its `---` frontmatter")
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
	assert(closed, "Unreleased change frontmatter is not closed with `---`")

	local bodyLines = {}
	for j = index, #lines do
		table.insert(bodyLines, lines[j])
	end
	local body = chomp(table.concat(bodyLines, "\n"))
	assert(body ~= "", "Unreleased change has no body")

	local bump = parseVersionComponent(fields.bump)
	local category = fields.category
	if category == nil or category == "" then
		category = DEFAULT_CATEGORY
	end

	return {
		bump = bump,
		category = category,
		body = body,
	}
end

return parseUnreleasedChange
