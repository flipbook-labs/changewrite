export type State = "success" | "failure"

export type StatusRequest = {
	repo: string,
	sha: string,
	state: State,
	context: string,
	description: string,
	url: string?,
}

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

return buildStatusArgs
