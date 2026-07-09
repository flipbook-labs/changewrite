--[[
	The publish PR's merge lock is a commit status posted to the publish branch's
	head. A release run fails it while it regenerates the PR and clears it once
	the PR matches its base again, so the PR cannot be merged while it is out of
	date. These are the pure pieces: the status message per state and the `gh api`
	argument list. The I/O (resolving a branch head, invoking gh) lives in the
	`lock` command, so this can be tested without reaching GitHub.
]]

export type State = "success" | "failure"

export type StatusRequest = {
	-- `owner/name` of the repository the status belongs to.
	repo: string,
	-- The commit the status is attached to.
	sha: string,
	state: State,
	-- The status context, i.e. the name it shows up under as a check.
	context: string,
	description: string,
	-- Optional link the status points at, e.g. the release run.
	url: string?,
}

-- The context the publish PR's lock uses. Make this a required status check on
-- the base branch for the lock to actually block a merge.
local DEFAULT_CONTEXT = "publish-lock"

local function describe(state: State): string
	if state == "failure" then
		return "A release run is updating the publish PR, so it is out of date"
	end

	return "The publish PR is up to date with its base branch"
end

-- `gh api` exits non-zero for any non-2xx response, so the `lock` command needs
-- to tell "the branch does not exist yet" (no publish PR has been opened, a
-- no-op) apart from a real failure like a network error or a GitHub 5xx, which
-- must fail loudly rather than leave the lock unset. A missing ref answers 404.
local function isMissingRefError(stderr: string): boolean
	return string.find(stderr, "HTTP 404", 1, true) ~= nil
end

-- The `gh api` argument list that posts `request` as a commit status.
local function buildStatusArgs(request: StatusRequest): { string }
	local args = {
		"api",
		"--method",
		"POST",
		`repos/{request.repo}/statuses/{request.sha}`,
		"-f",
		`state={request.state}`,
		"-f",
		`context={request.context}`,
		"-f",
		`description={request.description}`,
	}

	if request.url and request.url ~= "" then
		table.insert(args, "-f")
		table.insert(args, `target_url={request.url}`)
	end

	return args
end

return {
	DEFAULT_CONTEXT = DEFAULT_CONTEXT,
	describe = describe,
	buildStatusArgs = buildStatusArgs,
	isMissingRefError = isMissingRefError,
}
