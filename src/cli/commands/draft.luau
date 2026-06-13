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

-- A `v*` tag means at least one release already exists, which is how we tell a
-- first release apart from a routine one.
local function hasExistingReleaseTag(): boolean
	local result = process.run({ config.gitCmd, "tag", "--list", "v*" })
	assert(result.ok, result.stderr)
	return result.stdout:match("%S") ~= nil
end

local function getHeadCommit(): string
	local result = process.run({ config.gitCmd, "rev-parse", "HEAD" })
	assert(result.ok, result.stderr)
	return (result.stdout:gsub("%s+$", ""))
end

-- Pick the commit the release tag should point at.
local function resolveTargetCommit(version: string): string
	-- The first release is special. There's no prior tag, and the version string
	-- can have existed since the repo's root commit (e.g. a base version
	-- committed with the initial scaffolding) -- which is exactly where the
	-- version-source lookup lands. Tagging the root commit is rejected by the
	-- API: a parentless commit has no prior tree, so pointing a ref at it counts
	-- as *introducing* its `.github/workflows` files, which needs a `workflows`
	-- permission the Actions GITHUB_TOKEN can't be granted. "Release everything
	-- up to now" (HEAD) is also the natural meaning of a first release, so tag
	-- that instead.
	if not hasExistingReleaseTag() then
		return getHeadCommit()
	end

	-- Otherwise tag the commit that set this version rather than whichever commit
	-- happened to trip the gate. Routine version bumps are ordinary commits, so
	-- this never lands on the root.
	return assert(
		getLastVersionBumpCommit(version),
		`Could not find the commit that set version {version} in the configured version source`
	)
end

local function draft()
	local current = parser:get("version") or getCurrentVersion()
	local tag = `v{current}`

	local sha = resolveTargetCommit(current)

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
