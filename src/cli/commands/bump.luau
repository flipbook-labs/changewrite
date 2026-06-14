local cli = require("@batteries/cli")
local json = require("@std/json")

local getCurrentVersion = require("@root/release/getCurrentVersion")
local getNextVersion = require("@root/release/getNextVersion")
local parseVersion = require("@root/release/parseVersion")
local parseVersionComponent = require("@root/release/parseVersionComponent")
local prepareReleaseFiles = require("@root/release/prepareReleaseFiles")
local types = require("@root/cli/types")

local title = "bump"
local summary = "Move the version (and changelog) forward, e.g. to step past a tag that can't be published."

local parser = cli.parser()
parser:add("bump", "option", {
	help = "Which semver component to bump (major | minor | patch).",
	default = "patch",
})
parser:add("to", "option", {
	help = "Bump to an exact version (e.g. 1.4.0) instead of incrementing a component.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function bump()
	local current = getCurrentVersion()

	-- `--to` sets an exact version (validated as semver); otherwise step the
	-- requested component off the current version.
	local target = parser:get("to")
	local nextVersion: string
	if target then
		parseVersion(target)
		nextVersion = target
	else
		nextVersion = getNextVersion(current, parseVersionComponent(parser:get("bump")))
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
