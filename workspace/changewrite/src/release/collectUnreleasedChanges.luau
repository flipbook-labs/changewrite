local fs = require("@std/fs")
local path = require("@std/path")

local findMarkdownEntries = require("@root/release/findMarkdownEntries")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local isEntryFileName = require("@root/release/isEntryFileName")
local parseEntryFiles = require("@root/release/parseEntryFiles")
local readCategories = require("@root/release/readCategories")
local readKindNames = require("@root/release/readKindNames")
local types = require("@root/release/types")

type ParsedEntryFiles = types.ParsedEntryFiles

-- Reads every entry in the unreleased-changes directory. Returns the entries
-- that parse, and a problem for each entry that doesn't parse or is still
-- written in Markdown, sorted by file name.
local function collectUnreleasedChanges(): ParsedEntryFiles
	local dir = getUnreleasedChangesDir()
	local categories = readCategories()
	local kinds = readKindNames()
	if not fs.exists(dir) then
		return {
			changes = {},
			problems = {},
		}
	end

	local files: { parseEntryFiles.EntryFile } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type == "file" and isEntryFileName(entry.name) then
			local file = path.join(dir, entry.name)
			table.insert(files, {
				file = file,
				source = fs.readFileToString(file),
			})
		end
	end
	local result = parseEntryFiles(files, categories, kinds)

	-- Only Luau files are read above, so without these problems a Markdown
	-- entry would be left out of the release with no error.
	for _, file in findMarkdownEntries() do
		table.insert(result.problems, {
			file = file,
			problem = "This is a Markdown entry. Run `changewrite check --fix` to convert it to Luau.",
		})
	end
	table.sort(result.problems, function(a: types.EntryProblem, b: types.EntryProblem)
		return tostring(a.file) < tostring(b.file)
	end)

	return result
end

return collectUnreleasedChanges
