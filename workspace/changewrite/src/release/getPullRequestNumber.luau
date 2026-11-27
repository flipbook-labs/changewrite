local json = require("@std/json")

-- The pull request's number, or nil when the event isn't a pull request.
local function getPullRequestNumber(event: json.Object?): number?
	local pullRequest = if event then json.asObject(event.pull_request) else nil
	local number = if pullRequest then pullRequest.number else nil
	return if typeof(number) == "number" then number else nil
end

return getPullRequestNumber
