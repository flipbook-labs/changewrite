local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

local attachCommand = require("@root/cli/commands/attach")
local draftCommand = require("@root/cli/commands/draft")
local gateCommand = require("@root/cli/commands/gate")
local notesCommand = require("@root/cli/commands/notes")
local preparePrCommand = require("@root/cli/commands/preparePr")
local publishCommand = require("@root/cli/commands/publish")

local title = "help"
local summary = "Show this help message"

local function run()
	helpText.printRoot({
		title = "changewrite",
		summary = "Manage release readiness, changelogs, tags, and GitHub releases.",
		commands = {
			{
				name = "gate",
				description = gateCommand.summary,
			},
			{
				name = "draft",
				description = draftCommand.summary,
			},
			{
				name = "attach",
				description = attachCommand.summary,
			},
			{
				name = "publish",
				description = publishCommand.summary,
			},
			{
				name = "notes",
				description = notesCommand.summary,
			},
			{
				name = "prepare-pr",
				description = preparePrCommand.summary,
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
