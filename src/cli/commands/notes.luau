local cli = require("@batteries/cli")

local getCurrentVersion = require("@root/release/getCurrentVersion")
local renderReleaseNotes = require("@root/release/renderReleaseNotes")
local types = require("@root/cli/types")

local title = "notes"
local summary = "Print the Markdown notes for a version (the body of its GitHub release)."

local parser = cli.parser()
parser:add("version", "option", {
	help = "Version to render notes for, with or without a leading `v` (e.g. 1.2.3). Defaults to the configured changewrite version source.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function notes()
	local version = parser:get("version") or getCurrentVersion()
	-- Tolerate an optional leading `v` so `--version v1.2.3` and `--version 1.2.3`
	-- both resolve to the `v1.2.3` tag instead of silently rendering as `vv1.2.3`.
	local tag = `v{(version:gsub("^v", ""))}`
	print(renderReleaseNotes(tag))
end

local command: types.Command = {
	run = notes,
	title = title,
	summary = summary,
	parser = parser,
}

return command
