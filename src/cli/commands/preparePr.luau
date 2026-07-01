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

	local tagExists = process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/v{current}` }).ok

	local nextVersion = current
	if tagExists and bumpKind then
		nextVersion = getNextVersion(current, bumpKind)
	end
	local changedFiles = prepareReleaseFiles(nextVersion, changes)

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
