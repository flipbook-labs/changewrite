local DEFAULT_PATTERNS: { [string]: string } = {
	["changewrite.toml"] = "current%s*=%s*[\"']([^\"']+)[\"']",
	["loom.config.luau"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["wally.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["rotriever.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["Cargo.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["package.json"] = "[\"']version[\"']%s*:%s*[\"']([^\"']+)[\"']",
}

-- DEFAULT_PATTERNS is keyed by file and has no stable iteration order. Keep the
-- manifests in the order that `init` should emit them.
local MIRROR_MANIFESTS: { string } = {
	"loom.config.luau",
	"wally.toml",
	"Cargo.toml",
	"rotriever.toml",
	"package.json",
}

return {
	CHANGELOG_FILE = "CHANGELOG.md",
	CONFIG_FILE = "changewrite.toml",
	DEFAULT_CATEGORIES = {
		"Features",
		"Fixes",
		"Changes",
		"Dependencies",
	},
	DEFAULT_PATTERNS = DEFAULT_PATTERNS,
	DEFAULT_UNRELEASED_CHANGES_DIR = "./.changes/",
	MIRROR_MANIFESTS = MIRROR_MANIFESTS,
	-- The commit-status context the publish lock posts under. Make this a
	-- required status check on the base branch for the lock to block a merge.
	PUBLISH_LOCK_CONTEXT = "publish-lock",

	-- The branch a release run regenerates the publish PR on, and the branch
	-- `lock`/`unlock` mark by default. Mirrors the action's `branch` input.
	PUBLISH_BRANCH = "publish-next-version",
}
