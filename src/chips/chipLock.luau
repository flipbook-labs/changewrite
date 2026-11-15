local json = require("@std/json")

local planChips = require("@root/chips/planChips")

type ChipFiles = planChips.ChipFiles
type PlannedChip = planChips.PlannedChip

export type LockedChip = {
	text: string,
	hash: string,
	files: ChipFiles,
}

-- Keyed like `PlannedChip.key`.
export type ChipLock = { [string]: LockedChip }

local function quote(value: string): string
	local escaped = value:gsub('[%c"\\]', function(character: string): string
		if character == '"' or character == "\\" then
			return "\\" .. character
		end
		return string.format("\\u%04x", string.byte(character))
	end)
	return `"{escaped}"`
end

-- Written by hand rather than with a JSON serializer, so keys always come out
-- in the same order and regenerating an unchanged lockfile leaves no diff.
local function serialize(planned: { PlannedChip }): string
	local sorted = table.clone(planned)
	table.sort(sorted, function(a: PlannedChip, b: PlannedChip)
		return a.key < b.key
	end)

	local entries: { string } = {}
	for _, chip in sorted do
		table.insert(
			entries,
			table.concat({
				`    {quote(chip.key)}: \{`,
				`      "text": {quote(chip.text)},`,
				`      "hash": {quote(chip.hash)},`,
				`      "light": {quote(chip.files.light)},`,
				`      "dark": {quote(chip.files.dark)},`,
				`      "fallback": {quote(chip.files.fallback)}`,
				"    }",
			}, "\n")
		)
	end
	return `\{\n  "chips": \{\n{table.concat(entries, ",\n")}\n  }\n}\n`
end

local function parse(text: string): ChipLock
	local root = json.asObject(json.deserialize(text))
	assert(root, "Chip lockfile must be a JSON object")
	local chips = json.asObject(root.chips)
	assert(chips, 'Chip lockfile needs a "chips" object')

	local lock: ChipLock = {}
	for key, value in chips do
		-- Parsed objects carry a marker key that isn't a string.
		if typeof(key) ~= "string" then
			continue
		end
		local entry = json.asObject(value)
		assert(entry, `Chip lockfile entry "{key}" must be an object`)
		local function field(name: string): string
			local fieldValue = entry[name]
			assert(typeof(fieldValue) == "string", `Chip lockfile entry "{key}" needs a "{name}" string`)
			return fieldValue
		end
		lock[key] = {
			text = field("text"),
			hash = field("hash"),
			files = {
				light = field("light"),
				dark = field("dark"),
				fallback = field("fallback"),
			},
		}
	end
	return lock
end

return {
	serialize = serialize,
	parse = parse,
}
