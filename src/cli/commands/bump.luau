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

-- True when `a` (major, minor, patch) is strictly newer than `b`.
local function isNewer(a: { number }, b: { number }): boolean
	for i = 1, 3 do
		if a[i] ~= b[i] then
			return a[i] > b[i]
		end
	end
	return false
end

local function bump()
	local current = getCurrentVersion()
	local target = assert(parser:get("version"), "Missing required argument: version")

	-- `major`/`minor`/`patch` step the current version; anything else is an exact
	-- target, which we validate and guard against an accidental downgrade.
	local nextVersion: string
	if target == "major" or target == "minor" or target == "patch" then
		nextVersion = getNextVersion(current, target)
	else
		local nMajor, nMinor, nPatch = parseVersion(target)
		local cMajor, cMinor, cPatch = parseVersion(current)
		assert(
			isNewer({ nMajor, nMinor, nPatch }, { cMajor, cMinor, cPatch }),
			`Refusing to bump backward: {target} is not newer than the current version {current}`
		)
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
