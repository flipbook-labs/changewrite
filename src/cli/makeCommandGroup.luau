local process = require("@std/process")
local richterm = require("@batteries/richterm")

local helpText = require("@root/cli/helpText")
local runCommand = require("@root/cli/runCommand")
local types = require("@root/cli/types")

type Subcommands = { [string]: types.Command }

export type Options = {
	-- Token that appears in the argv stream (e.g. "release").
	name: string,
	title: string,
	summary: string,
	subcommands: Subcommands,
	-- Display order for the help listing.
	order: { string },
}

-- Find the word following `parentName` in `args` (the nested subcommand) and
-- its index. Flags (leading `-`) are skipped; the first non-flag token after
-- `parentName` is the subcommand.
local function findSubcommand(args: { string }, parentName: string): (string?, number?)
	local seenParent = false
	for i, arg in args do
		if arg:sub(1, 1) == "-" then
			continue
		elseif seenParent then
			return arg, i
		elseif arg == parentName then
			seenParent = true
		end
	end
	return nil, nil
end

-- Build a types.Command that dispatches to a fixed set of named subcommands.
-- Each subcommand gets its own `--help` / parse-error handling via runCommand.
local function makeCommandGroup(options: Options): types.Command
	local function printGroupHelp()
		local commands: { { name: string, description: string } } = {}
		for _, name in options.order do
			table.insert(commands, {
				name = name,
				description = options.subcommands[name].summary,
			})
		end
		helpText.printRoot({
			title = `changewrite {options.title}`,
			summary = options.summary,
			commands = commands,
			footer = `For more information: changewrite {options.title} <command> --help`,
		})
	end

	local function run(args: { string })
		local subName, index = findSubcommand(args, options.name)

		if not subName or not index or subName == "help" then
			printGroupHelp()
			return
		end

		local command = options.subcommands[subName]
		if not command then
			print(richterm.red(`Error: unknown {options.name} subcommand "{subName}"`))
			print()
			printGroupHelp()
			process.exit(1)
		end

		-- Hand the subcommand only the args after its name so its parser sees a
		-- clean argument list (variadics aren't polluted by the group name itself).
		local subArgs = table.move(args, index + 1, #args, 1, {})
		runCommand(command, subArgs)
	end

	return {
		run = run,
		title = options.title,
		summary = options.summary,
	}
end

return makeCommandGroup
