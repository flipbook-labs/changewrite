export type State = "success" | "failure"

export type StatusRequest = {
	repo: string,
	sha: string,
	state: State,
	context: string,
	description: string,
	url: string?,
}

local function describe(state: State): string
	if state == "failure" then
		return "A release run is updating the publish PR, so it is out of date"
	end

	return "The publish PR is up to date with its base branch"
end

-- `gh api` exits non-zero for any non-2xx response, so the caller has to tell a
-- missing branch (no publish PR opened yet, a no-op) apart from a real failure
-- like a network error or a 5xx, which must fail loudly. A missing ref is a 404.
local function isMissingRefError(stderr: string): boolean
	return string.find(stderr, "HTTP 404", 1, true) ~= nil
end

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
	describe = describe,
	buildStatusArgs = buildStatusArgs,
	isMissingRefError = isMissingRefError,
}
