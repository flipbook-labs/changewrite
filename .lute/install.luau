local fs = require("@std/fs")
local luau = require("@std/luau")
local process = require("@std/process")

local CONFIG_PATH = ".config.luau"
local LOCKFILE_PATH = "pkg.lock.luau"

-- `lute pkg install` puts each dependency in the Loom store, `~/.loom/store`,
-- under a folder whose name includes hashes of its source and rev. A dependency
-- with a `target` in `pkg.luau` installs only that subfolder, like Lute's
-- `batteries`. The lockfile records where each one landed, but `lute check`,
-- `lute compile`, and editors read aliases only from `.config.luau`. So after
-- installing, this writes the recorded path of each dependency that code
-- requires into that dependency's alias. Keys are aliases in `.config.luau`,
-- and values are dependency names in `pkg.luau`.
local DEPENDENCY_ALIASES: { [string]: string } = {
	batteries = "Lute",
	flipbookBatteries = "FlipbookBatteries",
}

type Lockfile = {
	dependencies: { [string]: string },
	devDependencies: { [string]: string }?,
	packages: { [string]: { installPath: string } },
}

local function getStorePath(lockfile: Lockfile, name: string): string
	local key = lockfile.dependencies[name] or (lockfile.devDependencies and lockfile.devDependencies[name])
	assert(key, `{name} is not a dependency in {LOCKFILE_PATH}`)

	-- The lockfile writes `@pkg/` for the store, and the path of a dependency
	-- without a target ends in `/.`.
	local installPath = lockfile.packages[key].installPath
	return (installPath:gsub("^@pkg/", "~/.loom/store/"):gsub("/%.$", ""))
end

local result = process.run({ "lute", "pkg", "install" }, { stdio = "inherit" })
assert(result.ok, "lute pkg install failed")

local lockfile: Lockfile = luau.loadModule(LOCKFILE_PATH)
local config = fs.readFileToString(CONFIG_PATH)

for alias, name in DEPENDENCY_ALIASES do
	local storePath = getStorePath(lockfile, name)
	local updated, count = config:gsub(`(%f[%w]{alias}%s*=%s*")[^"]*(")`, `%1{storePath}%2`)
	assert(count == 1, `Expected one "{alias}" alias in {CONFIG_PATH}, found {count}`)
	config = updated
end

fs.writeStringToFile(CONFIG_PATH, config)
print(`wrote dependency aliases to {CONFIG_PATH}`)
