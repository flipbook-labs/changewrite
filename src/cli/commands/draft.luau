local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.12.0")
local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local chomp = require("@root/chomp")
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

	--[[
		For the first release there are no prior `v*` tags, and the version
		string may have existed since the root commit (e.g. committed with
		initial scaffolding).

		We've been hitting issues with creating a release for this root commit
		centering around "workflow" permissions. This may be a general
		bootstrapping issue, or it might just be because we can't make a release
		(with GITHUB_TOKEN) when the commit we're publishing _also_ has
		workflows in it.

		In any case, we work around this by making sure the first release points
		at HEAD to bootstrap the project into the Changewrite release flow.
	]]
	local existingTags = process.run({ config.gitCmd, "tag", "--list", "v*" })
	assert(existingTags.ok, existingTags.stderr)
	local isFirstRelease = existingTags.stdout:match("%S") == nil

	local sha: string
	if isFirstRelease then
		local headResult = process.run({ config.gitCmd, "rev-parse", "HEAD" })
		assert(headResult.ok, headResult.stderr)
		sha = chomp(headResult.stdout)
	else
		-- Tag the commit that set this version rather than whichever commit
		-- happened to trip the gate.
		sha = assert(
			getLastVersionBumpCommit(current),
			`Could not find the commit that set version {current} in the configured version source`
		)
	end

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
