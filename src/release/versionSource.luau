local fs = require("@std/fs")
local path = require("@std/path")

local trim = require("@root/release/trim")

export type Target = {
	file: string,
	pattern: string?,
}

export type Config = {
	current: string?,
	source: Target,
	mirrors: { Target },
	unreleasedChangesDir: string,
}

local CONFIG_FILE = "changewrite.toml"
local DEFAULT_UNRELEASED_CHANGES_DIR = "./.changes/"

local DEFAULT_PATTERNS: { [string]: string } = {
	["changewrite.toml"] = "current%s*=%s*[\"']([^\"']+)[\"']",
	["loom.config.luau"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["wally.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["rotriever.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["package.json"] = "[\"']version[\"']%s*:%s*[\"']([^\"']+)[\"']",
}

local function stripComment(line: string): string
	local quote: string? = nil
	for i = 1, #line do
		local char = line:sub(i, i)
		if quote then
			if char == quote and line:sub(i - 1, i - 1) ~= "\\" then
				quote = nil
			end
		elseif char == '"' or char == "'" then
			quote = char
		elseif char == "#" then
			return line:sub(1, i - 1)
		end
	end
	return line
end

local function readStringField(text: string, key: string): string?
	local doubleQuoted = text:match(key .. '%s*=%s*"([^"]*)"')
	if doubleQuoted then
		return doubleQuoted
	end
	local singleQuoted = text:match(key .. "%s*=%s*'([^']*)'")
	return singleQuoted
end

local function parseTarget(text: string): Target?
	local file = readStringField(text, "file")
	if not file then
		return nil
	end
	return {
		file = file,
		pattern = readStringField(text, "pattern"),
	}
end

local function parseConfigText(text: string): Config
	local inVersionSection = false
	local inMirrorList = false
	local current: string? = nil
	local source: Target? = nil
	local sourcePattern: string? = nil
	local mirrors: { Target } = {}
	local unreleasedChangesDir: string? = nil

	for line in text:gmatch("[^\r\n]+") do
		local cleaned = trim(stripComment(line))
		if cleaned == "" then
			continue
		end

		local section = cleaned:match("^%[([^%]]+)%]$")
		if section then
			inVersionSection = section == "version"
			inMirrorList = false
			continue
		end

		unreleasedChangesDir = readStringField(cleaned, "unreleased_changes") or unreleasedChangesDir

		if not inVersionSection then
			continue
		end

		if inMirrorList then
			local target = parseTarget(cleaned)
			if target then
				table.insert(mirrors, target)
			end
			if cleaned:find("%]") then
				inMirrorList = false
			end
			continue
		end

		if cleaned:match("^mirror%s*=") then
			inMirrorList = true
			local target = parseTarget(cleaned)
			if target then
				table.insert(mirrors, target)
			end
			if cleaned:find("%]") then
				inMirrorList = false
			end
			continue
		end

		current = readStringField(cleaned, "current") or current
		sourcePattern = readStringField(cleaned, "pattern") or sourcePattern

		local configuredSource = parseTarget(cleaned)
		if configuredSource then
			source = configuredSource
		end
	end

	if source and not source.pattern then
		source.pattern = sourcePattern
	end

	return {
		current = current,
		source = source or {
			file = CONFIG_FILE,
			pattern = DEFAULT_PATTERNS[CONFIG_FILE],
		},
		mirrors = mirrors,
		unreleasedChangesDir = unreleasedChangesDir or DEFAULT_UNRELEASED_CHANGES_DIR,
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

local function getUnreleasedChangesDir(): string
	return readConfig().unreleasedChangesDir
end

return {
	_parseConfigText = parseConfigText,
	getCurrentVersion = getCurrentVersion,
	getUnreleasedChangesDir = getUnreleasedChangesDir,
	getSourceFile = getSourceFile,
	writeVersion = writeVersion,
}
