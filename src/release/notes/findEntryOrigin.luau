local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")

export type EntryOrigin = {
	-- The pull request named by the commit that added the entry.
	pr: number?,
	-- When that commit was made, in seconds since the Unix epoch.
	addedAt: number?,
}

-- Finds the commit that added an entry file. Squash merges on GitHub end the
-- commit subject with the pull request number, such as "Add a thing (#42)", so
-- that commit names the entry's PR, and its time is when the entry merged. An
-- entry that hasn't been committed yet has neither.
local function findEntryOrigin(file: path.Path): EntryOrigin
	local result = process.run({
		config.gitCmd,
		"log",
		"--diff-filter=A",
		"--format=%ct %s",
		"-n",
		"1",
		"--",
		tostring(file),
	})
	if not result.ok then
		return {}
	end

	local timestamp, subject = result.stdout:match("^(%d+) (.-)%s*$")
	if timestamp == nil or subject == nil then
		return {}
	end
	local number = subject:match("%(#(%d+)%)$")
	return {
		pr = if number then tonumber(number) else nil,
		addedAt = tonumber(timestamp),
	}
end

return findEntryOrigin
