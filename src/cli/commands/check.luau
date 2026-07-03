local cli = require("@batteries/cli")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local types = require("@root/cli/types")
local versionSource = require("@root/release/versionSource")

local title = "check"
local summary = "Fail when no unreleased changes are pending, to enforce a changelog entry per PR."

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function formatChangelogTemplate(): string
	return table.concat({
		"---",
		"bump: patch",
		"category: Fixes",
		"---",
		"",
		"One or two sentences describing the change, written for the changelog.",
	}, "\n")
end

local function printNoChangesError()
	local dir = versionSource.getUnreleasedChangesDir()

	print(richterm.red("A changelog entry is required."))
	print("")
	print(`Add a markdown entry under {richterm.bold(dir)} describing this change:`)
	print("")
	print(richterm.bold("Template:"))
	print(formatChangelogTemplate())
	print("")
	print(richterm.bold("Guide:"))
	print("  • bump (required): major, minor, or patch")
	print("  • category (optional): Features, Fixes, Dependencies, Changes (default)")
	print("  • filename: name after the change (e.g., fix-release-permissions.md)")
	print("  • body: changelog text, one or two sentences")
	print("")
	print(`See {dir}README.md for details.`)
end

local function run()
	local changes = readUnreleasedChanges()
	if #changes == 0 then
		printNoChangesError()
		process.exit(1)
	end

	print(`Found {#changes} pending unreleased changes.`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
