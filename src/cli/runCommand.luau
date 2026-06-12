local process = require("@std/process")
local richterm = require("@batteries/richterm")

local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

-- Parse a command's args, then run it. Handles `--help` and parse errors
-- uniformly so every level of the command tree (the root CLI and each command
-- group like `release`) gets the same help and error behavior.
local function runCommand(command: types.Command, args: { string })
	if command.parser then
		local ok, err = pcall(command.parser.parse, command.parser, args)
		if not ok then
			local message = tostring(err):match(":%d+: (.+)$") or tostring(err)
			print(richterm.red("Error: " .. message))
			print()
			helpText.print(command.parser, {
				title = command.title,
				summary = command.summary,
			})
			process.exit(1)
		end

		if command.parser:has("help") then
			helpText.print(command.parser, {
				title = command.title,
				summary = command.summary,
			})
			process.exit(0)
		end
	end

	command.run(args)
end

return runCommand
