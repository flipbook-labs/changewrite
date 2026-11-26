local path = require("@std/path")

local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")
local types = require("@root/release/types")

type EntryProblem = types.EntryProblem
type ParsedEntryFiles = types.ParsedEntryFiles
type UnreleasedChange = types.UnreleasedChange

export type EntryFile = {
	file: path.Path,
	source: string,
}

--[[
	An error from parsing an entry arrives prefixed with the Changewrite source
	file and line that raised it, such as a check in `parseUnreleasedChange`.
	That position tells someone fixing the entry nothing, so the prefix is
	dropped. Only the leading prefix goes: a syntax error keeps the line number
	inside the entry that comes later in the message.
]]
local function stripErrorPosition(err: unknown): string
	local message = tostring(err)
	return message:match("^[^\n]-:%d+: (.*)$") or message
end

--[[
	Parses every entry file, so one bad entry doesn't hide the ones after it.
	Each file that fails to parse becomes a problem naming the file and the
	reason, and the rest still parse into changes. Both lists come back sorted by
	file name.
]]
local function parseEntryFiles(files: { EntryFile }, categories: { string }?, kinds: { string }?): ParsedEntryFiles
	local sorted = table.clone(files)
	table.sort(sorted, function(a: EntryFile, b: EntryFile)
		return tostring(a.file) < tostring(b.file)
	end)

	local changes: { UnreleasedChange } = {}
	local problems: { EntryProblem } = {}
	for _, entry in sorted do
		local success, parsed = pcall(parseUnreleasedChange, entry.source, categories, kinds)
		if not success then
			table.insert(problems, {
				file = entry.file,
				problem = stripErrorPosition(parsed),
			})
			continue
		end
		table.insert(changes, {
			bump = parsed.bump,
			category = parsed.category,
			summary = parsed.summary,
			body = parsed.body,
			kind = parsed.kind,
			flags = parsed.flags,
			highlight = parsed.highlight,
			pr = parsed.pr,
			file = entry.file,
		})
	end

	return {
		changes = changes,
		problems = problems,
	}
end

return parseEntryFiles
