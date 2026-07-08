local cli = require("@batteries/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

local changelogHasVersion = require("@root/release/changelogHasVersion")
local config = require("@root/config")
local evaluateReleaseGate = require("@root/release/evaluateReleaseGate")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local readUnreleasedChanges = require("@root/release/readUnreleasedChanges")
local types = require("@root/cli/types")

local CHANGELOG_FILE = "CHANGELOG.md"

local title = "gate"
local summary = "Decide whether to publish the current version or prepare the next one."

local parser = cli.parser()
parser:add("force-publish", "flag", {
	help = "Publish the current version even if it already has a tag.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local current = getCurrentVersion()
	local tag = `v{current}`

	-- `rev-parse --verify` exits non-zero when the ref is missing, so its exit
	-- code answers whether the tag exists; `-q` silences the stderr it would print.
	local tagExists = process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/{tag}` }).ok

	-- A release was prepared for this version if `prepare-pr` already folded it
	-- into the changelog. Without that fingerprint an untagged version is just a
	-- pristine repo, not a release waiting to be published.
	local changelog = if fs.exists(CHANGELOG_FILE) then fs.readFileToString(CHANGELOG_FILE) else ""
	local releasePrepared = changelogHasVersion(changelog, current)

	local result = evaluateReleaseGate({
		version = current,
		forcePublish = parser:has("force-publish"),
		tagExists = tagExists,
		hasUnreleasedChanges = #readUnreleasedChanges() > 0,
		releasePrepared = releasePrepared,
	})

	-- Emit the decision as JSON on stdout so callers (the release workflow, or a
	-- person) can parse it. Deliberately environment-agnostic: the workflow is
	-- responsible for any GitHub Actions plumbing (e.g. piping into
	-- $GITHUB_OUTPUT), not the CLI.
	print(json.serialize({
		version = result.version,
		should_publish = result.shouldPublish,
		has_changes = result.hasChanges,
	}))
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
