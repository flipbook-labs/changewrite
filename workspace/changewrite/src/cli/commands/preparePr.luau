local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local json = require("@std/json")

local prepareReleaseFiles = require("@root/release/prepareReleaseFiles")
local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local resolveReleaseVersion = require("@root/release/resolveReleaseVersion")
local stringifyPaths = require("@root/stringifyPaths")
local types = require("@root/cli/types")

local title = "prepare-pr"
local summary = "Combine the pending unreleased changes and bump the version for the next release."

local parser = cli.parser()
parser:add("help", "flag", {
	help = "Show this help message",
})

local function preparePr()
	local changes = readUnreleasedChanges()
	assert(
		#changes > 0,
		"No unreleased changes found, so there is nothing to release. "
			.. "Add a markdown entry under the configured unreleased_changes directory."
	)

	local nextVersion = resolveReleaseVersion(changes)
	local changedFiles = stringifyPaths(prepareReleaseFiles(nextVersion, changes))

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
