local fs = require("@std/fs")
local path = require("@std/path")

local convertMarkdownEntry = require("@root/entries/convertMarkdownEntry")
local findMarkdownEntries = require("@root/release/findMarkdownEntries")

-- Replaces each Markdown changelog entry with a Luau entry, keeping its name
-- and swapping `.md` for `.luau`.
local function convertMarkdownEntryFiles()
	for _, file in findMarkdownEntries() do
		local target = path.parse(path.format(file):gsub("%.[mM][dD]$", ".luau"))
		assert(not fs.exists(target), `Can't convert {file}: {target} already exists`)
		local success, converted = pcall(convertMarkdownEntry, fs.readFileToString(file))
		assert(success, `{file}: {converted}`)
		fs.writeStringToFile(target, converted)
		fs.remove(file)
		print(`Converted {file} to {target}.`)
	end
end

return convertMarkdownEntryFiles
