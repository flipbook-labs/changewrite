local cli = require("@batteries/cli")
local json = require("@std/json")
local process = require("@std/process")

local computeBump = require("@root/release/computeBump")
local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local getNextVersion = require("@root/release/getNextVersion")
local prepareReleaseFiles = require("@root/release/prepareReleaseFiles")
local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local types = require("@root/cli/types")

local title = "prepare-pr"
local summary = "Combine the pending unreleased changes and bump the version for the next release."

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function preparePr()
	local current = getCurrentVersion()

	-- The pending changes describe the release: their cumulative bump picks the
	-- version, and their bodies become the changelog. With none there is nothing
	-- to do.
	local changes = readUnreleasedChanges()
	assert(
		#changes > 0,
		"No unreleased changes found, so there is nothing to release. "
			.. "Add a markdown entry under the configured unreleased_changes directory."
	)

	local bumps = {}
	for _, change in changes do
		table.insert(bumps, change.bump)
	end
	local bumpKind = computeBump(bumps)

	-- `rev-parse --verify` exits non-zero when the ref is missing, so its exit
	-- code answers whether the tag exists; `-q` silences the stderr it would print.
	local tagExists = process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/v{current}` }).ok

	-- If the current version is already tagged, bump to the next one; otherwise
	-- the version hasn't been released yet (e.g. the first release), so assemble
	-- the changes into it as-is. `bumpKind` is non-nil because `changes` is
	-- non-empty (asserted above); the `and bumpKind` narrows it for getNextVersion.
	local nextVersion = current
	if tagExists and bumpKind then
		nextVersion = getNextVersion(current, bumpKind)
	end
	local changedFiles = prepareReleaseFiles(nextVersion, changes)

	-- The bumped version, regenerated changelog, and deleted changes are left in
	-- the working tree; the caller commits them and opens the publish PR (the
	-- release workflow uses peter-evans/create-pull-request). Emit the next
	-- version as JSON so the caller can title the PR; deliberately
	-- environment-agnostic, like `gate`.
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
