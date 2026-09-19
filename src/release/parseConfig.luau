local toml = require("@batteries/toml")

local constants = require("@root/release/constants")

export type Target = {
	file: string,
	pattern: string?,
}

export type Config = {
	categories: { string }?,
	current: string?,
	source: Target,
	mirrors: { Target },
	unreleasedChangesDir: string,
}

local function readString(value: toml.TomlValue?): string?
	return if typeof(value) == "string" then value else nil
end

local function readCategories(value: toml.TomlValue?): { string }?
	if value == nil then
		return nil
	end
	assert(typeof(value) == "table", "`categories` must be a non-empty array of strings")

	local categoryValues = value :: { toml.TomlValue }
	local categories = {}
	local seen = {}
	for _, category in categoryValues do
		assert(typeof(category) == "string" and category ~= "", "`categories` must be a non-empty array of strings")
		assert(not seen[category], `Duplicate changelog category "{category}"`)
		seen[category] = true
		table.insert(categories, category)
	end
	assert(#categories > 0 and #categories == #categoryValues, "`categories` must be a non-empty array of strings")
	return categories
end

local function parseTarget(value: toml.TomlValue): Target?
	if typeof(value) ~= "table" then
		return nil
	end

	local target = value :: { [string]: toml.TomlValue }
	local file = readString(target.file)
	if not file then
		return nil
	end

	return {
		file = file,
		pattern = readString(target.pattern),
	}
end

local function parseConfig(text: string): Config
	local parsed = toml.deserialize(text)

	local version = parsed.version
	local versionConfig: { [string]: toml.TomlValue } = if typeof(version) == "table"
		then version :: { [string]: toml.TomlValue }
		else {}

	local file = readString(versionConfig.file)
	local source: Target = if file
		then { file = file, pattern = readString(versionConfig.pattern) }
		else { file = constants.CONFIG_FILE, pattern = constants.DEFAULT_PATTERNS[constants.CONFIG_FILE] }

	local mirrors: { Target } = {}
	local mirror = versionConfig.mirror
	local single = parseTarget(mirror)
	if single then
		table.insert(mirrors, single)
	elseif typeof(mirror) == "table" then
		for _, entry in mirror :: { toml.TomlValue } do
			local target = parseTarget(entry)
			if target then
				table.insert(mirrors, target)
			end
		end
	end

	return {
		categories = readCategories(parsed.categories),
		current = readString(versionConfig.current),
		source = source,
		mirrors = mirrors,
		unreleasedChangesDir = readString(parsed.unreleased_changes) or constants.DEFAULT_UNRELEASED_CHANGES_DIR,
	}
end

return parseConfig
