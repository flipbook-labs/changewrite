local json = require("@std/json")

-- The commit at the tip of a pull request's head branch, or nil when the event
-- isn't a pull request. On a pull request, actions/checkout checks out a merge
-- of the head into the base rather than the head itself, so `HEAD` isn't the
-- branch's own tip.
local function getPullRequestHeadSha(event: json.Object?): string?
	local pullRequest = if event then json.asObject(event.pull_request) else nil
	local head = if pullRequest then json.asObject(pullRequest.head) else nil
	local sha = if head then head.sha else nil
	return if typeof(sha) == "string" and sha ~= "" then sha else nil
end

return getPullRequestHeadSha
