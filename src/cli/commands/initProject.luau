local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local richterm = require("@batteries/richterm")

local pickHighestVersion = require("@root/release/pickHighestVersion")
local renderInitConfig = require("@root/release/renderInitConfig")
local types = require("@root/cli/types")
local versionSource = require("@root/release/versionSource")

local title = "init"
local summary = "Scaffold a changewrite.toml, wiring up mirrors for the manifests it detects."

local DEFAULT_VERSION = "0.1.0"

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local configPath = path.resolve(versionSource.CONFIG_FILE)
	assert(
		not fs.exists(configPath),
		`{versionSource.CONFIG_FILE} already exists. Delete it first if you want to start over.`
	)

	local mirrors: { string } = {}
	local versions: { string } = {}
	for _, manifest in versionSource.MIRROR_MANIFESTS do
		if fs.exists(path.resolve(manifest)) then
			table.insert(mirrors, manifest)
			local version = versionSource.readOptionalVersion(manifest)
			if version then
				table.insert(versions, version)
			end
		end
	end

	-- A greenfield project has no pin to inherit, so seed a conventional starting
	-- version the user can freely edit in the generated file.
	local version = if #versions > 0 then pickHighestVersion(versions) else DEFAULT_VERSION

	fs.writeStringToFile(configPath, renderInitConfig(version, mirrors))

	print(`Wrote {richterm.bold(versionSource.CONFIG_FILE)} at version {richterm.bold(version)}.`)
	if #mirrors > 0 then
		print(`Mirroring: {table.concat(mirrors, ", ")}`)
	end
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
