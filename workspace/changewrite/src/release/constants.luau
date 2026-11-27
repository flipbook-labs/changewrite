local ChangeFlag = require("@root/release/ChangeFlag")

local DEFAULT_PATTERNS: { [string]: string } = {
	["changewrite.luau"] = "current%s*=%s*[\"']([^\"']+)[\"']",
	["pkg.luau"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["loom.config.luau"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["wally.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["rotriever.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["Cargo.toml"] = "version%s*=%s*[\"']([^\"']+)[\"']",
	["package.json"] = "[\"']version[\"']%s*:%s*[\"']([^\"']+)[\"']",
}

-- DEFAULT_PATTERNS is keyed by file and has no stable iteration order. Keep the
-- manifests in the order that `init` should emit them.
local MIRROR_MANIFESTS: { string } = {
	"pkg.luau",
	"loom.config.luau",
	"wally.toml",
	"Cargo.toml",
	"rotriever.toml",
	"package.json",
}

return {
	CHANGELOG_FILE = "CHANGELOG.md",
	-- Also the order of the allowed values named in validation errors.
	CHANGE_FLAGS = { ChangeFlag.Breaking, ChangeFlag.Deprecated, ChangeFlag.Security },
	CONFIG_FILE = "changewrite.luau",
	-- The config file Changewrite read before changewrite.luau. `check --fix`
	-- converts it, and every other command fails while it's present.
	LEGACY_CONFIG_FILE = "changewrite.toml",
	DEFAULT_CATEGORIES = {
		"Features",
		"Fixes",
		"Changes",
		"Dependencies",
	},
	DEFAULT_PATTERNS = DEFAULT_PATTERNS,
	-- The line a changelog preview puts where it leaves out entries or sections.
	EXCERPT_CUT = "…",
	-- How many entries a changelog preview keeps on each side of one the pull
	-- request adds, so the preview shows where that entry lands.
	EXCERPT_NEIGHBORS = 1,
	DEFAULT_UNRELEASED_CHANGES_DIR = "./.changes/",
	MIRROR_MANIFESTS = MIRROR_MANIFESTS,
	-- Maps a manifest to the newer manifest that replaces it. Lute reads
	-- `pkg.luau` and ignores `loom.config.luau`, so `init` mirrors only the
	-- newer file when a repo still has both.
	SUPERSEDED_MANIFESTS = {
		["loom.config.luau"] = "pkg.luau",
	} :: { [string]: string },
	-- The commit-status context the publish lock posts under. Make this a
	-- required status check on the base branch for the lock to block a merge.
	PUBLISH_LOCK_CONTEXT = "publish-lock",
	-- Starts the body of the pull request comment `changewrite preview --comment`
	-- posts, so a later run finds that comment to update or delete it.
	PREVIEW_COMMENT_MARKER = "<!-- changewrite-preview -->",

	-- The branch a release run regenerates the publish PR on when
	-- `release.branch` is unset. Mirrors the action's `branch` input default.
	PUBLISH_BRANCH = "publish-next-version",

	-- An optional file in the unreleased-changes directory holding the release's
	-- TL;DR. It is consumed with the entries but is not an entry itself.
	RELEASE_SUMMARY_FILE = "release.md",
}
