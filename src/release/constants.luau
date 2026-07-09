return {
	CHANGELOG_FILE = "CHANGELOG.md",

	-- The commit-status context the publish lock posts under. Make this a
	-- required status check on the base branch for the lock to block a merge.
	PUBLISH_LOCK_CONTEXT = "publish-lock",

	-- The branch a release run regenerates the publish PR on, and the branch
	-- `lock`/`unlock` mark by default. Mirrors the action's `branch` input.
	PUBLISH_BRANCH = "publish-next-version",
}
