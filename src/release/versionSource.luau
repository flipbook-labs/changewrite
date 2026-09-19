local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local parseConfig = require("@root/release/parseConfig")

type Target = parseConfig.Target
type Config = parseConfig.Config

local function readConfig(): Config
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(fs.exists(configPath), `Could not find {constants.CONFIG_FILE} in the current directory`)
	return parseConfig(fs.readFileToString(configPath))
end

local function patternFor(target: Target): string
	local pattern = target.pattern or constants.DEFAULT_PATTERNS[target.file]
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
	if config.source.file == constants.CONFIG_FILE and config.current then
		return config.current
	end
	return readTargetVersion(config.source)
end

local function getCategories(): { string }?
	return readConfig().categories
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

-- Read the version from a known manifest, or nil when the file is absent or
-- carries no recognizable version. Used by `init` to inherit an existing pin.
local function readOptionalVersion(file: string): string?
	local resolved = path.resolve(file)
	local pattern = constants.DEFAULT_PATTERNS[file]
	if not pattern or not fs.exists(resolved) then
		return nil
	end
	local version = fs.readFileToString(resolved):match(pattern)
	return version
end

return {
	getCategories = getCategories,
	getCurrentVersion = getCurrentVersion,
	getUnreleasedChangesDir = getUnreleasedChangesDir,
	getSourceFile = getSourceFile,
	readOptionalVersion = readOptionalVersion,
	writeVersion = writeVersion,
}
