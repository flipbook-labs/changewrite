local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local storeDir = path.join(process.homedir(), ".loom/store")
local packagesDir = path.resolve("packages")

if not fs.exists(packagesDir) then
	fs.createDirectory(packagesDir)
end

process.run({
	"lute",
	"pkg",
	"install",
}, {
	stdio = "inherit",
})

local config = require("@repo/loom.config")
local lock = require("@repo/loom.lock")

-- Dev dependencies (agent guidance) are installed into ~/.loom/store so agents
-- can read them, but they carry no Luau the binary needs, so they are excluded
-- from the packages/ copy that feeds the bundle.
local devPackageIds: { [string]: boolean } = {}
for alias in config.package.dev_dependencies or {} do
	local packageId = lock.dependencies[alias]
	if packageId then
		devPackageIds[packageId] = true
	end
end

process.run({ "rm", "-rf", tostring(packagesDir) }, { stdio = "inherit" })
fs.createDirectory(packagesDir)

-- Lute doesn't seem able to bundle `~/.loom/store` yet, so we need to copy the
-- packages into our project directory to allow them to be part of the bundle.
for packageId in lock.packages do
	if devPackageIds[packageId] then
		continue
	end
	local src = path.join(storeDir, packageId)
	local dst = path.join(packagesDir, packageId)
	if not fs.exists(dst) then
		process.run({ "cp", "-r", tostring(src), tostring(dst) }, { stdio = "inherit" })
	end
end
