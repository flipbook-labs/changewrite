local fs = require("@std/fs")
local path = require("@std/path")

local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local isMarkdownEntryFileName = require("@root/release/isMarkdownEntryFileName")

local function findMarkdownEntries(): { path.Path }
	local dir = getUnreleasedChangesDir()
	if not fs.exists(dir) then
		return {}
	end

	local files: { path.Path } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type == "file" and isMarkdownEntryFileName(entry.name) then
			table.insert(files, path.join(dir, entry.name))
		end
	end
	table.sort(files, function(a: path.Path, b: path.Path)
		return tostring(a) < tostring(b)
	end)
	return files
end

return findMarkdownEntries
