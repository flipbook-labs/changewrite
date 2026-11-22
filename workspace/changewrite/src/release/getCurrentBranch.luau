local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")

-- Pull request checkouts on GitHub Actions are detached at a merge commit, so
-- the PR's branch only exists as GITHUB_HEAD_REF.
local function getCurrentBranch(): string?
	local headRef = process.env.GITHUB_HEAD_REF
	if headRef and headRef ~= "" then
		return headRef
	end

	local result = process.run({
		config.gitCmd,
		"branch",
		"--show-current",
	})
	if not result.ok then
		return nil
	end

	local branch = chomp(result.stdout)
	return if branch ~= "" then branch else nil
end

return getCurrentBranch
