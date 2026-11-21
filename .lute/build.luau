local fs = require("@std/fs")
local process = require("@std/process")
local project = require("@repo/project")
local system = require("@lute/system")

local outputPath = tostring(project.BUILD_OUTPUT)
if string.lower(system.os) == "windows_nt" then
	outputPath = outputPath .. ".exe"
end

if fs.exists(outputPath) then
	fs.remove(outputPath)
end

if not fs.exists(project.BUILD_PATH) then
	fs.createDirectory(project.BUILD_PATH, { makeParents = true })
end

local result = process.run({
	"lute",
	"compile",
	"workspace/changewrite/cli.luau",
	"--output",
	outputPath,
	"--bundle-stats",
	"--show-require-graph",
}, {
	stdio = "inherit",
})
assert(result.ok, "lute compile failed")

-- A binary missing a package still compiles but fails on its first require,
-- so this runs it once to catch that.
local smoke = process.run({ outputPath, "--help" })
assert(smoke.ok, `{outputPath} failed to start: {smoke.stderr}`)
