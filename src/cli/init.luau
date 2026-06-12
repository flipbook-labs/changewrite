local runCommand = require("@self/runCommand")
local types = require("@self/types")

local helpCommand = require("@self/commands/help")
local releaseCommand = require("@self/commands/release")

local function findSubcommand(args: { string }): string?
	local i = 2
	while i <= #args do
		local arg = args[i]
		if string.sub(arg, 1, 2) == "--" then
			i += 2
		elseif string.sub(arg, 1, 1) == "-" then
			i += 1
		else
			return arg
		end
	end
	return nil
end

local availableCommands: { [string]: types.Command } = {
	release = releaseCommand,
	help = helpCommand,
}

local function run(args: { string })
	local subcommand = findSubcommand(args)
	local command: types.Command = (subcommand and availableCommands[subcommand]) or availableCommands.help

	runCommand(command, args)
end

return {
	run = run,
}
