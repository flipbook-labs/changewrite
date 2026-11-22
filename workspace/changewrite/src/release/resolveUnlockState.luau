local buildStatusArgs = require("@root/release/buildStatusArgs")

export type UnlockInput = {
	-- The commit the unlock would post to.
	sha: string,
	-- Whether the caller named the commit directly instead of a branch.
	isExplicitSha: boolean,
	-- The publish branch's current head, or nil when there is no publish branch.
	publishHead: string?,
	-- The base commit the release run refreshed the publish branch from.
	baseSha: string?,
	-- The base branch's current head.
	baseHead: string?,
}

-- Returns the state an unlock should post, or nil to post nothing.
--
-- Commit statuses belong to commits, not pull requests, so a pull request whose
-- head is the publish branch's commit (such as one from a fork) would unlock the
-- publish PR too. The release run owns that commit's status, so an explicit sha
-- that matches it is left alone.
--
-- When the base branch has moved past the commit the publish branch was
-- refreshed from, the publish PR is missing that change, so it gets locked
-- instead. A newer release run refreshes and unlocks it.
local function resolveUnlockState(input: UnlockInput): buildStatusArgs.State?
	if input.isExplicitSha and input.sha == input.publishHead then
		return nil
	end

	if input.baseSha and input.baseHead ~= input.baseSha then
		return "failure"
	end

	return "success"
end

return resolveUnlockState
