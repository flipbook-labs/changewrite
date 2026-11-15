local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local richterm = require("@batteries/richterm")

local constants = require("@root/release/constants")
local parseVersion = require("@root/semver/parseVersion")
local pickHighestVersion = require("@root/semver/pickHighestVersion")
local readOptionalVersion = require("@root/release/readOptionalVersion")
local renderInitConfig = require("@root/release/renderInitConfig")
local stringifyPaths = require("@root/stringifyPaths")
local types = require("@root/cli/types")

local title = "init"
local summary = "Scaffold a changewrite.toml, wiring up mirrors for the manifests it detects."

local DEFAULT_VERSION = "0.1.0"

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local configPath = path.resolve(constants.CONFIG_FILE)
	assert(
		not fs.exists(configPath),
		`{constants.CONFIG_FILE} already exists. Delete it first if you want to start over.`
	)

	local mirrors: { path.Path } = {}
	local versions: { string } = {}
	for _, manifest in constants.MIRROR_MANIFESTS do
		local manifestPath = path.parse(manifest)
		if fs.exists(manifestPath) then
			table.insert(mirrors, manifestPath)
			-- changewrite tracks plain X.Y.Z versions, so parseVersion rejects a
			-- prerelease or build suffix a manifest might carry. Mirror the file
			-- regardless and skip its version so init falls back instead of crashing.
			local version = readOptionalVersion(manifestPath)
			if version and pcall(parseVersion, version) then
				table.insert(versions, version)
			elseif version then
				print(`Ignoring unsupported version {richterm.bold(version)} in {manifestPath}.`)
			end
		end
	end

	-- A greenfield project has no pin to inherit, so seed a conventional starting
	-- version the user can freely edit in the generated file.
	local version = if #versions > 0 then pickHighestVersion(versions) else DEFAULT_VERSION

	fs.writeStringToFile(configPath, renderInitConfig(version, mirrors))

	print(`Wrote {richterm.bold(constants.CONFIG_FILE)} at version {richterm.bold(version)}.`)
	if #mirrors > 0 then
		print(`Mirroring: {table.concat(stringifyPaths(mirrors), ", ")}`)
	end
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
