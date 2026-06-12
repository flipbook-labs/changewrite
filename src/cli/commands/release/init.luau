local makeCommandGroup = require("@root/cli/makeCommandGroup")

local attachCommand = require("@self/attach")
local draftCommand = require("@self/draft")
local gateCommand = require("@self/gate")
local notesCommand = require("@self/notes")
local preparePrCommand = require("@self/preparePr")
local publishCommand = require("@self/publish")

return makeCommandGroup({
	name = "release",
	title = "release",
	summary = "Manage the release lifecycle (gate, draft, attach, publish, notes, prepare-pr).",
	subcommands = {
		gate = gateCommand,
		draft = draftCommand,
		attach = attachCommand,
		publish = publishCommand,
		notes = notesCommand,
		["prepare-pr"] = preparePrCommand,
	},
	order = { "gate", "draft", "attach", "publish", "notes", "prepare-pr" },
})
