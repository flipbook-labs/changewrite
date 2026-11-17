local fs = require("@std/fs")
local luau = require("@std/luau")
local path = require("@std/path")
local process = require("@std/process")
local project = require("@repo/project")
local system = require("@lute/system")

-- `lute compile` stores each file the entry requires at a path relative to the
-- deepest folder all of those files share. Inside the binary, an alias that
-- starts with `~/` resolves against that shared folder, not the home folder.
-- The committed `.config.luau` points dependency aliases at the Loom store, the
-- folder in `~/.loom/store` where `lute pkg install` puts packages. So a binary
-- compiled from the checkout loads its dependencies only when the checkout sits
-- under the home folder. On Windows, a checkout on a different drive from the
-- home folder doesn't compile at all.
--
-- So this compiles from a stage folder inside `build/`. It copies the sources
-- there, and copies each package that `pkg.lock.luau` records into `store/`
-- beside them, at the same path it has in the store. In every copied
-- `.config.luau` and `.luaurc`, `~/.loom/store` becomes the relative path to
-- that `store/` folder.
-- That covers the root aliases and any package whose own aliases point at
-- another package in the store, so every require resolves inside the stage.
local STAGE_PATH = path.join(project.BUILD_PATH, "stage")
local STAGED_STORE_PATH = path.join(STAGE_PATH, "store")
local STORE_PATH = path.join(process.homedir(), ".loom", "store")
local SOURCES = { "cli.luau", "src", "libs" }
local CONFIG_FILES = { [".config.luau"] = true, [".luaurc"] = true }

type Lockfile = {
	dependencies: { [string]: string },
	devDependencies: { [string]: string }?,
	packages: { [string]: { installPath: string } },
}

-- Copies with `fs` rather than `cp`, which Windows lacks. `storeFromHere` is
-- the relative path from `dest` to the staged store folder, which replaces
-- `~/.loom/store` in config files.
local function copyDirectory(src: path.Path, dest: path.Path, storeFromHere: string)
	fs.createDirectory(dest, { makeParents = true })
	for _, entry in fs.listDirectory(src) do
		local from = path.join(src, entry.name)
		local to = path.join(dest, entry.name)
		if entry.type == "dir" then
			copyDirectory(from, to, `../{storeFromHere}`)
		elseif CONFIG_FILES[entry.name] then
			local config = fs.readFileToString(from):gsub("~/%.loom/store", storeFromHere)
			fs.writeStringToFile(to, config)
		else
			fs.copy(from, to)
		end
	end
end

local outputPath = tostring(project.BUILD_OUTPUT)
if string.lower(system.os) == "windows_nt" then
	outputPath = outputPath .. ".exe"
end

if fs.exists(outputPath) then
	fs.remove(outputPath)
end

if fs.exists(STAGE_PATH) then
	fs.removeDirectory(STAGE_PATH, { recursive = true })
end
fs.createDirectory(STAGE_PATH, { makeParents = true })

for _, source in SOURCES do
	local to = path.join(STAGE_PATH, source)
	if fs.type(source) == "dir" then
		copyDirectory(path.parse(source), to, "../store")
	else
		fs.copy(source, to)
	end
end

local config = fs.readFileToString(".config.luau"):gsub("~/%.loom/store", "./store")
fs.writeStringToFile(path.join(STAGE_PATH, ".config.luau"), config)

-- Each package's store path comes from its `installPath`. A package installed
-- with a `target` records only that subfolder of its store folder, like Lute's
-- `batteries`, so only that part is copied. Copying all of Lute would also
-- push some paths past Windows' 260-character limit. Dev dependencies aren't
-- bundled, so they're skipped.
local lockfile: Lockfile = luau.loadModule("pkg.lock.luau")
local devOnly: { [string]: boolean } = {}
for _, key in lockfile.devDependencies or {} do
	devOnly[key] = true
end
for _, key in lockfile.dependencies do
	devOnly[key] = nil
end

for key, package in lockfile.packages do
	if not devOnly[key] then
		local relative = package.installPath:gsub("^@pkg/", ""):gsub("/%.$", "")
		local _, depth = relative:gsub("/", "")
		local storeFromHere = string.rep("../", depth) .. ".."
		copyDirectory(path.join(STORE_PATH, relative), path.join(STAGED_STORE_PATH, relative), storeFromHere)
	end
end

local result = process.run({
	"lute",
	"compile",
	"cli.luau",
	"--output",
	outputPath,
	"--bundle-stats",
	"--show-require-graph",
}, {
	cwd = tostring(STAGE_PATH),
	stdio = "inherit",
})
assert(result.ok, "lute compile failed")

-- A binary missing a package still compiles but fails on its first require,
-- so this runs it once to catch that.
local smoke = process.run({ outputPath, "--help" })
assert(smoke.ok, `{outputPath} failed to start: {smoke.stderr}`)
