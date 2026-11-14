local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")
local readCategories = require("@root/release/readCategories")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function readUnreleasedChanges(): { UnreleasedChange }
	local dir = getUnreleasedChangesDir()
	local categories = readCategories()
	if not fs.exists(dir) then
		return {}
	end

	local changes: { UnreleasedChange } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type ~= "file" or not entry.name:match("%.md$") then
			continue
		end
		local lowerName = entry.name:lower()
		if lowerName == "readme.md" or lowerName == constants.RELEASE_SUMMARY_FILE then
			continue
		end

		local file = path.join(dir, entry.name)
		local success, parsed = pcall(parseUnreleasedChange, fs.readFileToString(file), categories)
		assert(success, `{file}: {parsed}`)
		table.insert(changes, {
			bump = parsed.bump,
			category = parsed.category,
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
