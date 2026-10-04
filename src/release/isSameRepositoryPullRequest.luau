local json = require("@std/json")

local function getRepoName(side: json.Value): string?
	local ref = json.asObject(side)
	local repo = if ref then json.asObject(ref.repo) else nil
	local name = if repo then repo.full_name else nil
	return if typeof(name) == "string" and name ~= "" then name else nil
end

-- A fork's branch can share a name with one of the repository's own branches,
-- so a branch name alone never proves a pull request comes from the
-- repository. Anything short of matching head and base repositories, including
-- a missing payload or a deleted fork, counts as a fork.
local function isSameRepositoryPullRequest(event: json.Object?): boolean
	local pullRequest = if event then json.asObject(event.pull_request) else nil
	if not pullRequest then
		return false
	end

	local head = getRepoName(pullRequest.head)
	local base = getRepoName(pullRequest.base)
	return head ~= nil and head == base
end

return isSameRepositoryPullRequest
