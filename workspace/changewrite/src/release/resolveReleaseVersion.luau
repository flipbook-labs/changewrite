local process = require("@std/process")

local computeBump = require("@root/release/computeBump")
local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local resolveNextVersion = require("@root/release/resolveNextVersion")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- The version a release of `changes` gets, from the configured version, whether
-- it's tagged yet, and the largest bump among the changes.
local function resolveReleaseVersion(changes: { UnreleasedChange }): string
	local current = getCurrentVersion()

	local bumps = {}
	for _, change in changes do
		table.insert(bumps, change.bump)
	end

	local tagExists = process.run({
		config.gitCmd,
		"rev-parse",
		"-q",
		"--verify",
		`refs/tags/v{current}`,
	}).ok

	return resolveNextVersion(current, tagExists, computeBump(bumps))
end

return resolveReleaseVersion
