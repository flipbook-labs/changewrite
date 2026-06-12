local runCommand = require("@self/runCommand")
local types = require("@self/types")

local attachCommand = require("@self/commands/attach")
local draftCommand = require("@self/commands/draft")
local gateCommand = require("@self/commands/gate")
local helpCommand = require("@self/commands/help")
local notesCommand = require("@self/commands/notes")
local preparePrCommand = require("@self/commands/preparePr")
local publishCommand = require("@self/commands/publish")

-- Find the command word in `args` and its index. Flags (leading `-`) are
-- skipped; the first non-flag token is the command. Index 1 is the program
-- name, so the scan starts at 2.
local function findSubcommand(args: { string }): (string?, number?)
	local i = 2
	while i <= #args do
		local arg = args[i]
		if string.sub(arg, 1, 2) == "--" then
			i += 2
		elseif string.sub(arg, 1, 1) == "-" then
			i += 1
		else
			return arg, i
		end
	end
	return nil, nil
end

local availableCommands: { [string]: types.Command } = {
	gate = gateCommand,
	draft = draftCommand,
	attach = attachCommand,
	publish = publishCommand,
	notes = notesCommand,
	["prepare-pr"] = preparePrCommand,
	help = helpCommand,
}

local function run(args: { string })
	local subcommand, index = findSubcommand(args)
	local command: types.Command = (subcommand and availableCommands[subcommand]) or availableCommands.help

	-- Hand the command only the args after its name so its parser sees a clean
	-- argument list (variadics aren't polluted by the program or command name).
	local subArgs = if index then table.move(args, index + 1, #args, 1, {}) else {}

	runCommand(command, subArgs)
end

return {
	run = run,
}
