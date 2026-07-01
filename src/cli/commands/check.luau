local cli = require("@batteries/cli")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local types = require("@root/cli/types")
local versionSource = require("@root/release/versionSource")

local title = "check"
local summary = "Fail when no unreleased changes are pending, to enforce a changelog entry per PR."

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local changes = readUnreleasedChanges()
	if #changes == 0 then
		local dir = versionSource.getUnreleasedChangesDir()
		print(richterm.red(`A changelog entry is required. Add a markdown entry under {dir} describing this change.`))
		process.exit(1)
	end

	print(`Found {#changes} pending unreleased changes.`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
