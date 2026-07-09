local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

local attachCommand = require("@root/cli/commands/attach")
local bumpCommand = require("@root/cli/commands/bump")
local checkCommand = require("@root/cli/commands/check")
local draftCommand = require("@root/cli/commands/draft")
local gateCommand = require("@root/cli/commands/gate")
local lockCommand = require("@root/cli/commands/lock")
local notesCommand = require("@root/cli/commands/notes")
local preparePrCommand = require("@root/cli/commands/preparePr")
local publishCommand = require("@root/cli/commands/publish")
local unlockCommand = require("@root/cli/commands/unlock")

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
				name = "bump",
				description = bumpCommand.summary,
			},
			{
				name = "check",
				description = checkCommand.summary,
			},
			{
				name = "lock",
				description = lockCommand.summary,
			},
			{
				name = "unlock",
				description = unlockCommand.summary,
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
