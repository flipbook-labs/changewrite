local cli = require("@batteries/cli")
local json = require("@std/json")

local getCurrentVersion = require("@root/release/getCurrentVersion")
local getNextVersion = require("@root/release/getNextVersion")
local parseVersion = require("@root/release/parseVersion")
local prepareReleaseFiles = require("@root/release/prepareReleaseFiles")
local readChangePartials = require("@root/release/readChangePartials")
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
	local target = parser:get("version") :: string

	local nextVersion: string
	if target == "major" or target == "minor" or target == "patch" then
		nextVersion = getNextVersion(getCurrentVersion(), target)
	else
		parseVersion(target)
		nextVersion = target
	end

	-- Fold whatever partials are pending into the forced version, the same way
	-- `prepare-pr` does. There may be none (this is an escape hatch for stepping
	-- past a burned tag), in which case only the version moves.
	local changedFiles = prepareReleaseFiles(nextVersion, readChangePartials())

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
