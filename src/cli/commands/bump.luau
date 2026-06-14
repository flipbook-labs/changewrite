local cli = require("@batteries/cli")
local json = require("@std/json")

local getCurrentVersion = require("@root/release/getCurrentVersion")
local getNextVersion = require("@root/release/getNextVersion")
local parseVersion = require("@root/release/parseVersion")
local prepareReleaseFiles = require("@root/release/prepareReleaseFiles")
local types = require("@root/cli/types")

local title = "bump"
local summary = "Move the version (and changelog) forward, e.g. to step past a tag that can't be published."

local parser = cli.parser()
parser:add("version", "positional", {
	help = "A semver component (major | minor | patch) to step, or an exact version like 1.2.3 to set.",
	required = true,
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function bump()
	-- `version` is required, so the parser guarantees a value by the time we run.
	local target = parser:get("version") :: string

	-- `major`/`minor`/`patch` step the current version. Anything else is an exact
	-- target. We deliberately allow it to be lower than the current version --
	-- redoing a release sometimes means going back, and the publish PR is the
	-- real guard against an unwanted version.
	local nextVersion: string
	if target == "major" or target == "minor" or target == "patch" then
		nextVersion = getNextVersion(getCurrentVersion(), target)
	else
		parseVersion(target)
		nextVersion = target
	end

	local changedFiles = prepareReleaseFiles(nextVersion)

	-- Same contract as `prepare-pr`: leave the bumped version + regenerated
	-- changelog in the working tree and emit the new version as JSON so a caller
	-- can open the publish PR.
	print(json.serialize({
		version = nextVersion,
		changed_files = changedFiles,
	}))
end

local command: types.Command = {
	run = bump,
	title = title,
	summary = summary,
	parser = parser,
}

return command
