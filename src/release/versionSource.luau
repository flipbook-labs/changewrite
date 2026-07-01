local fs = require("@std/fs")
local path = require("@std/path")
local toml = require("@batteries/toml")

export type Target = {
	file: string,
	pattern: string?,
}

export type Config = {
	current: string?,
	source: Target,
	mirrors: { Target },
}

local CONFIG_FILE = "changewrite.toml"

local DEFAULT_PATTERNS: { [string]: string } = {
	["changewrite.toml"] = "current%s*=%s*[\"']([^\"']+)[\"']",
	["loom.config.luau"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["wally.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["rotriever.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["package.json"] = "[\"']version[\"']%s*:%s*[\"']([^\"']+)[\"']",
}

local function readString(value: toml.TomlValue?): string?
	return if typeof(value) == "string" then value else nil
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

local function parseConfigText(text: string): Config
	local parsed = toml.deserialize(text)

	local version = parsed.version
	local versionConfig: { [string]: toml.TomlValue } = if typeof(version) == "table"
		then version :: { [string]: toml.TomlValue }
		else {}

	local file = readString(versionConfig.file)
	local source: Target = if file
		then { file = file, pattern = readString(versionConfig.pattern) }
		else { file = CONFIG_FILE, pattern = DEFAULT_PATTERNS[CONFIG_FILE] }

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
		current = readString(versionConfig.current),
		source = source,
		mirrors = mirrors,
	}
end

local function readConfig(): Config
	local configPath = path.resolve(CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {CONFIG_FILE} in the current directory`)
	return parseConfigText(fs.readFileToString(configPath))
end

local function patternFor(target: Target): string
	local pattern = target.pattern or DEFAULT_PATTERNS[target.file]
	assert(pattern, `No version pattern configured for {target.file}`)
	return pattern
end

local function replaceCapturedVersion(content: string, pattern: string, nextVersion: string, file: string): string
	local startIndex, endIndex, currentVersion = content:find(pattern)
	assert(startIndex and endIndex and currentVersion, `Could not find a version in {file}`)

	local matched = content:sub(startIndex, endIndex)
	local relativeStart, relativeEnd = matched:find(currentVersion, 1, true)
	assert(relativeStart and relativeEnd, `Could not locate captured version in {file}`)

	return table.concat({
		content:sub(1, startIndex + relativeStart - 2),
		nextVersion,
		content:sub(startIndex + relativeEnd),
	})
end

local function readTargetVersion(target: Target): string
	local file = path.resolve(target.file)
	local content = fs.readFileToString(file)
	local version = content:match(patternFor(target))
	assert(version, `Could not find a version in {file}`)
	return version
end

local function writeTargetVersion(target: Target, nextVersion: string): ()
	local file = path.resolve(target.file)
	local content = fs.readFileToString(file)
	local updated = replaceCapturedVersion(content, patternFor(target), nextVersion, tostring(file))
	fs.writeStringToFile(file, updated)
end

local function getCurrentVersion(): string
	local config = readConfig()
	if config.source.file == CONFIG_FILE and config.current then
		return config.current
	end
	return readTargetVersion(config.source)
end

local function writeVersion(nextVersion: string): { string }
	local config = readConfig()
	local changedFiles = { config.source.file }
	writeTargetVersion(config.source, nextVersion)

	for _, mirror in config.mirrors do
		writeTargetVersion(mirror, nextVersion)
		table.insert(changedFiles, mirror.file)
	end

	return changedFiles
end

local function getSourceFile(): string
	return readConfig().source.file
end

return {
	_parseConfigText = parseConfigText,
	getCurrentVersion = getCurrentVersion,
	getSourceFile = getSourceFile,
	writeVersion = writeVersion,
}
