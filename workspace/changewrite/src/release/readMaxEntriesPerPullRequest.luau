local parseMaxEntriesPerPullRequest = require("@root/release/parseMaxEntriesPerPullRequest")
local readConfig = require("@root/release/readConfig")

local function readMaxEntriesPerPullRequest(): number
	return parseMaxEntriesPerPullRequest(readConfig())
end

return readMaxEntriesPerPullRequest
