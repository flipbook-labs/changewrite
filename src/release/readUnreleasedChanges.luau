local fs = require("@std/fs")
local path = require("@std/path")

local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")
local types = require("@root/release/types")
local versionSource = require("@root/release/versionSource")

type UnreleasedChange = types.UnreleasedChange

local function readUnreleasedChanges(): { UnreleasedChange }
	local dir = versionSource.getUnreleasedChangesDir()
	if not fs.exists(dir) then
		return {}
	end

	local changes: { UnreleasedChange } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type ~= "file" or not entry.name:match("%.md$") then
			continue
		end
		if entry.name:lower() == "readme.md" then
			continue
		end

		local file = tostring(path.normalize(path.join(dir, entry.name)))
		local parsed = parseUnreleasedChange(fs.readFileToString(file))
		table.insert(changes, {
			bump = parsed.bump,
			category = parsed.category,
			body = parsed.body,
			file = file,
		})
	end

	table.sort(changes, function(a: UnreleasedChange, b: UnreleasedChange)
		return a.file < b.file
	end)
	return changes
end

return readUnreleasedChanges
