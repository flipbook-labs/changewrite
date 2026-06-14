local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.11.1")

local config = require("@root/config")
local writeVersion = require("@root/release/writeVersion")

local run = FlipbookBatteries.run

-- Write a version across the configured source + mirrors and regenerate the
-- changelog so unreleased commits land under that version's tag. Returns the
-- files whose version string changed (the changelog is always touched too, so
-- callers add it themselves). Shared by `prepare-pr` and `bump`, which differ
-- only in how they pick the next version.
local function prepareReleaseFiles(nextVersion: string): { string }
	local changedFiles = writeVersion(nextVersion)

	run(config.gitCliffCmd, {
		"--config",
		"cliff.toml",
		"--tag",
		`v{nextVersion}`,
		"--output",
		"CHANGELOG.md",
	})

	return changedFiles
end

return prepareReleaseFiles
