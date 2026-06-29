local fs = require("@std/fs")
local path = require("@std/path")

local getNextVersion = require("@root/release/getNextVersion")
local parseVersionComponent = require("@root/release/parseVersionComponent")
local versionSource = require("@root/release/versionSource")

type VersionComponent = getNextVersion.VersionComponent

-- A single unreleased change, parsed from one markdown file in the change
-- partials directory.
export type Partial = {
	-- How large a version bump this change warrants.
	bump: VersionComponent,
	-- The changelog section this entry belongs under (e.g. "Features").
	category: string,
	-- The entry text shown in the changelog (the markdown body).
	body: string,
	-- Repo-relative path of the source file, so callers can delete it and report
	-- the deletion in the publish PR.
	file: string,
}

-- Parsed frontmatter + body, before a file path is attached.
type ParsedPartial = {
	bump: VersionComponent,
	category: string,
	body: string,
}

local DEFAULT_CATEGORY = "Changes"

local function trim(value: string): string
	return (value:gsub("^%s+", ""):gsub("%s+$", ""))
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

-- Split into lines while preserving blank lines, so the body keeps its original
-- paragraph spacing.
local function splitLines(text: string): { string }
	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, (line:gsub("\r$", "")))
	end
	return lines
end

-- Parse a single change partial's `---`-fenced frontmatter and markdown body.
-- Exposed as `_parsePartial` for tests.
local function parsePartial(text: string): ParsedPartial
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

-- Read and parse every `.md` change partial in the configured directory.
-- Returns an empty list when the directory doesn't exist (nothing pending).
-- Sorted by path so the changelog and bump are deterministic.
local function read(): { Partial }
	local dir = versionSource.getChangePartialsDir()
	if not fs.exists(dir) then
		return {}
	end

	local partials: { Partial } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type ~= "file" or not entry.name:match("%.md$") then
			continue
		end
		-- A README documents the folder for humans, so it isn't a change entry.
		if entry.name:lower() == "readme.md" then
			continue
		end

		local file = tostring(path.normalize(path.join(dir, entry.name)))
		local parsed = parsePartial(fs.readFileToString(file))
		table.insert(partials, {
			bump = parsed.bump,
			category = parsed.category,
			body = parsed.body,
			file = file,
		})
	end

	table.sort(partials, function(a: Partial, b: Partial)
		return a.file < b.file
	end)
	return partials
end

-- Delete the given partial files once they've been folded into the changelog.
local function remove(files: { string }): ()
	for _, file in files do
		fs.remove(file)
	end
end

return {
	_parsePartial = parsePartial,
	read = read,
	remove = remove,
}
