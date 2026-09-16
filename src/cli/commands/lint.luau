local cli = require("@batteries/cli")

local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local types = require("@root/cli/types")

local title = "lint"
local summary = "Validate all unreleased changelog entries."

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local changes = readUnreleasedChanges()
	local noun = if #changes == 1 then "entry" else "entries"
	print(`Validated {#changes} unreleased change {noun}.`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
