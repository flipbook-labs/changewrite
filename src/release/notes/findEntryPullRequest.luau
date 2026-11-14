local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")

-- Squash merges on GitHub end the commit subject with the pull request number,
-- such as "Add a thing (#42)", so the commit that added an entry names its PR.
local function findEntryPullRequest(file: path.Path): number?
	local result = process.run({
		config.gitCmd,
		"log",
		"--diff-filter=A",
		"--format=%s",
		"-n",
		"1",
		"--",
		tostring(file),
	})
	if not result.ok then
		return nil
	end

	local number = result.stdout:match("%(#(%d+)%)%s*$")
	return if number then tonumber(number) else nil
end

return findEntryPullRequest
