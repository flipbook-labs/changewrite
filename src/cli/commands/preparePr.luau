local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.11.1")
local cli = require("@batteries/cli")
local json = require("@std/json")
local process = require("@std/process")

local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local getNextVersion = require("@root/release/getNextVersion")
local types = require("@root/cli/types")
local writeVersion = require("@root/release/writeVersion")

local run = FlipbookBatteries.run

type VersionComponent = getNextVersion.VersionComponent

local title = "prepare-pr"
local summary = "Bump the version and regenerate the changelog for the next release."

local parser = cli.parser()
parser:add("bump", "option", {
	help = "Which semver component to bump when preparing the next release (major | minor | patch).",
	default = "minor",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function preparePr()
	local current = getCurrentVersion()

	local bumpOption = parser:get("bump")
	local bumpKind: VersionComponent
	if bumpOption == "major" then
		bumpKind = "major"
	elseif bumpOption == "patch" then
		bumpKind = "patch"
	elseif bumpOption == "minor" then
		bumpKind = "minor"
	else
		error(`Unknown version component "{bumpOption}"`)
	end

	-- `rev-parse --verify` exits non-zero when the ref is missing, so its exit
	-- code answers whether the tag exists; `-q` silences the stderr it would print.
	local tagExists = process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/v{current}` }).ok

	-- If the current version is already tagged, bump to the next one; otherwise
	-- the version hasn't been released yet, so prepare it as-is.
	local nextVersion = if tagExists then getNextVersion(current, bumpKind) else current
	local nextTag = `v{nextVersion}`

	local changedFiles = writeVersion(nextVersion)
	-- Regenerate the full changelog, treating unreleased commits as `nextTag`.
	run(config.gitCliffCmd, {
		"--config",
		"cliff.toml",
		"--tag",
		nextTag,
		"--output",
		"CHANGELOG.md",
	})

	-- The bumped version and regenerated changelog are left in the working tree;
	-- the caller commits them and opens the publish PR (the release workflow uses
	-- peter-evans/create-pull-request). Emit the next version as JSON so the
	-- caller can title the PR; deliberately environment-agnostic, like `gate`.
	print(json.serialize({
		version = nextVersion,
		changed_files = changedFiles,
	}))
end

local command: types.Command = {
	run = preparePr,
	title = title,
	summary = summary,
	parser = parser,
}

return command
