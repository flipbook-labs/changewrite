local fs = require("@std/fs")
local path = require("@std/path")

local findMarkdownEntries = require("@root/release/findMarkdownEntries")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local isEntryFileName = require("@root/release/isEntryFileName")
local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")
local readCategories = require("@root/release/readCategories")
local readKindNames = require("@root/release/readKindNames")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function readUnreleasedChanges(): { UnreleasedChange }
	local dir = getUnreleasedChangesDir()
	local categories = readCategories()
	local kinds = readKindNames()
	if not fs.exists(dir) then
		return {}
	end

	-- The loop below reads only Luau files, so without this check a Markdown
	-- entry would be left out of the release with no error.
	local markdownEntries = findMarkdownEntries()
	assert(
		#markdownEntries == 0,
		`{markdownEntries[1]} is a Markdown entry. Run \`changewrite check --fix\` to convert it to Luau.`
	)

	local changes: { UnreleasedChange } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type ~= "file" or not isEntryFileName(entry.name) then
			continue
		end

		local file = path.join(dir, entry.name)
		local success, parsed = pcall(parseUnreleasedChange, fs.readFileToString(file), categories, kinds)
		assert(success, `{file}: {parsed}`)
		table.insert(changes, {
			bump = parsed.bump,
			category = parsed.category,
			summary = parsed.summary,
			body = parsed.body,
			kind = parsed.kind,
			flags = parsed.flags,
			highlight = parsed.highlight,
			pr = parsed.pr,
			file = file,
		})
	end

	table.sort(changes, function(a: UnreleasedChange, b: UnreleasedChange)
		return tostring(a.file) < tostring(b.file)
	end)
	return changes
end

return readUnreleasedChanges
