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
	-- Kinds sort in this order within a category. Both lists also set the order
	-- of the allowed values named in validation errors.
	CHANGE_FLAGS = { "api", "deprecated", "security" },
	CHANGE_KINDS = { "new", "improved", "fixed", "breaking" },
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

	-- The branch a release run regenerates the publish PR on when
	-- `release.branch` is unset. Mirrors the action's `branch` input default.
	PUBLISH_BRANCH = "publish-next-version",

	-- An optional file in the unreleased-changes directory holding the release's
	-- TL;DR and name. It is consumed with the entries but is not an entry itself.
	RELEASE_SUMMARY_FILE = "release.md",
}
