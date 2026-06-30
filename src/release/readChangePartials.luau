local fs = require("@std/fs")
local path = require("@std/path")

local parseChangePartial = require("@root/release/parseChangePartial")
local versionSource = require("@root/release/versionSource")

export type ChangelogEntry = parseChangePartial.ParsedChangePartial & {
	file: string,
}

local function readChangePartials(): { ChangelogEntry }
	local dir = versionSource.getChangePartialsDir()
	if not fs.exists(dir) then
		return {}
	end

	local entries: { ChangelogEntry } = {}
	for _, entry in fs.listDirectory(dir) do
		if entry.type ~= "file" or not entry.name:match("%.md$") then
			continue
		end
		if entry.name:lower() == "readme.md" then
			continue
		end

		local file = tostring(path.normalize(path.join(dir, entry.name)))
		local parsed = parseChangePartial(fs.readFileToString(file))
		table.insert(entries, {
			bump = parsed.bump,
			category = parsed.category,
			body = parsed.body,
			file = file,
		})
	end

	table.sort(entries, function(a: ChangelogEntry, b: ChangelogEntry)
		return a.file < b.file
	end)
	return entries
end

return readChangePartials
