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

local lock = require("@repo/loom.lock")

process.run({ "rm", "-rf", tostring(packagesDir) }, { stdio = "inherit" })
fs.createDirectory(packagesDir)

-- Lute doesn't seem able to bundle `~/.loom/store` yet, so we need to copy the
-- packages into our project directory to allow them to be part of the bundle.
for packageId in lock.packages do
	local src = path.join(storeDir, packageId)
	local dst = path.join(packagesDir, packageId)
	if not fs.exists(dst) then
		process.run({ "cp", "-r", tostring(src), tostring(dst) }, { stdio = "inherit" })
	end
end
