local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

local releaseCommand = require("@root/cli/commands/release")

local title = "help"
local summary = "Show this help message"

local function run()
	helpText.printRoot({
		title = "changewrite",
		summary = "Manage release readiness, changelogs, tags, and GitHub releases.",
		commands = {
			{
				name = "release",
				description = releaseCommand.summary,
			},
			{
				name = "help",
				description = summary,
			},
		},
	})
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
}

return command
