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
-- So this builds from a staging folder inside `build/`. It copies the sources
-- there, along with the store folder of each alias that points into the store.
-- Then it writes a `.config.luau` that points those aliases at the copies,
-- keeps the other aliases as they are, and compiles from that folder. The
-- `lute` and `std` aliases also start with `~/`, but `lute compile` builds
-- those libraries in, so every bundled file lives under the staging folder.
local STAGING_PATH = path.join(project.BUILD_PATH, "staging")
local SOURCES = { "cli.luau", "src", "libs" }
local STORE_PREFIX = "~/.loom/store/"

local function copyDirectory(src: path.Path, dest: path.Path)
	fs.createDirectory(dest, { makeParents = true })
	for _, entry in fs.listDirectory(src) do
		local from = path.join(src, entry.name)
		local to = path.join(dest, entry.name)
		if entry.type == "dir" then
			copyDirectory(from, to)
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

if fs.exists(STAGING_PATH) then
	fs.removeDirectory(STAGING_PATH, { recursive = true })
end
fs.createDirectory(STAGING_PATH, { makeParents = true })

for _, source in SOURCES do
	local to = path.join(STAGING_PATH, source)
	if fs.type(source) == "dir" then
		copyDirectory(path.parse(source), to)
	else
		fs.copy(source, to)
	end
end

local config = luau.loadModule(".config.luau")
local aliasLines = {}
for alias, target in config.luau.aliases do
	if target:sub(1, #STORE_PREFIX) == STORE_PREFIX then
		local storePath = path.join(process.homedir(), target:sub(3))
		copyDirectory(storePath, path.join(STAGING_PATH, "packages", alias))
		target = `./packages/{alias}`
	end
	table.insert(aliasLines, `\t\t\t[{string.format("%q", alias)}] = {string.format("%q", target)},`)
end
table.sort(aliasLines)

fs.writeStringToFile(
	path.join(STAGING_PATH, ".config.luau"),
	`return \{\n\tluau = \{\n\t\tlanguagemode = "strict",\n\t\taliases = \{\n{table.concat(aliasLines, "\n")}\n\t\t},\n\t},\n}\n`
)

local result = process.run({
	"lute",
	"compile",
	"cli.luau",
	"--output",
	outputPath,
	"--bundle-stats",
	"--show-require-graph",
}, {
	cwd = tostring(STAGING_PATH),
	stdio = "inherit",
})
assert(result.ok, "lute compile failed")
