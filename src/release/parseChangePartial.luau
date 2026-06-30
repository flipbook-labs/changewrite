local getNextVersion = require("@root/release/getNextVersion")
local parseVersionComponent = require("@root/release/parseVersionComponent")

type VersionComponent = getNextVersion.VersionComponent

export type ParsedChangePartial = {
	bump: VersionComponent,
	category: string,
	body: string,
}

local DEFAULT_CATEGORY = "Changes"

local function trim(value: string): string
	local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
	return trimmed
end

local function stripQuotes(value: string): string
	local doubleQuoted = value:match('^"(.*)"$')
	if doubleQuoted then
		return doubleQuoted
	end
	local singleQuoted = value:match("^'(.*)'$")
	if singleQuoted then
		return singleQuoted
	end
	return value
end

local function splitLines(text: string): { string }
	local lines = string.split(text, "\n")
	for index, line in lines do
		local stripped = line:gsub("\r$", "")
		lines[index] = stripped
	end
	return lines
end

local function parseChangePartial(text: string): ParsedChangePartial
	local lines = splitLines(text)

	local index = 1
	while index <= #lines and trim(lines[index]) == "" do
		index += 1
	end
	assert(trim(lines[index] or "") == "---", "Change partial is missing its `---` frontmatter")
	index += 1

	local fields: { [string]: string } = {}
	local closed = false
	while index <= #lines do
		local line = lines[index]
		index += 1
		if trim(line) == "---" then
			closed = true
			break
		end
		local key, value = line:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
		if key ~= nil and value ~= nil then
			fields[key] = stripQuotes(value)
		end
	end
	assert(closed, "Change partial frontmatter is not closed with `---`")

	local bodyLines = {}
	for j = index, #lines do
		table.insert(bodyLines, lines[j])
	end
	local body = trim(table.concat(bodyLines, "\n"))
	assert(body ~= "", "Change partial has no body")

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

return parseChangePartial
