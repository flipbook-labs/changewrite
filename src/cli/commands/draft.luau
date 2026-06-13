local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local getLastVersionBumpCommit = require("@root/release/getLastVersionBumpCommit")
local getTempDir = require("@root/getTempDir")
local renderReleaseNotes = require("@root/release/renderReleaseNotes")
local types = require("@root/cli/types")

local run = FlipbookBatteries.run

local title = "draft"
local summary = "Tag the current version and open a draft GitHub release with generated notes."

local parser = cli.parser()
parser:add("version", "option", {
	help = "Version to draft. Defaults to the configured changewrite version source.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function draft()
	local current = parser:get("version") or getCurrentVersion()
	local tag = `v{current}`

	-- Tag the commit that set this version rather than whichever commit happened
	-- to trip the gate.
	local sha = assert(
		getLastVersionBumpCommit(current),
		`Could not find the commit that set version {current} in the configured version source`
	)

	if process.run({ config.ghCmd, "release", "view", tag }).ok then
		print(`Release {tag} already exists`)
		return
	end

	-- Same renderer the publish PR uses for its preview, so the drafted notes and
	-- the previewed notes can't drift. The tag doesn't exist locally yet, so
	-- renderReleaseNotes renders the unreleased commits under the prospective tag.
	local notesPath = path.join(getTempDir(), "release-notes.md")
	fs.writeStringToFile(notesPath, renderReleaseNotes(tag))

	run(config.ghCmd, {
		"release",
		"create",
		tag,
		"--draft",
		"--title",
		tag,
		"--target",
		sha,
		"--notes-file",
		tostring(notesPath),
	})
	print(`Created draft release {tag}`)
end

local command: types.Command = {
	run = draft,
	title = title,
	summary = summary,
	parser = parser,
}

return command
