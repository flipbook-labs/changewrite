local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")

local REMOTE_PREFIX = "origin/"

local function readEventDefaultBranch(): string?
	local eventPath = process.env.GITHUB_EVENT_PATH
	if not eventPath or eventPath == "" or not fs.exists(eventPath) then
		return nil
	end

	local event = json.asObject(json.deserialize(fs.readFileToString(eventPath)))
	local repository = if event then json.asObject(event.repository) else nil
	local branch = if repository then repository.default_branch else nil
	return if typeof(branch) == "string" and branch ~= "" then branch else nil
end

-- git records the remote's default branch as `refs/remotes/origin/HEAD` on
-- clone. actions/checkout does not create it, which is why the GitHub Actions
-- sources are checked first.
local function readRemoteHead(): string?
	local result = process.run({
		config.gitCmd,
		"symbolic-ref",
		"--short",
		"refs/remotes/origin/HEAD",
	})
	if not result.ok then
		return nil
	end

	local ref = chomp(result.stdout)
	if ref:sub(1, #REMOTE_PREFIX) ~= REMOTE_PREFIX then
		return nil
	end
	return ref:sub(#REMOTE_PREFIX + 1)
end

local function resolveBaseBranch(): string?
	local baseRef = process.env.GITHUB_BASE_REF
	if baseRef and baseRef ~= "" then
		return baseRef
	end

	return readEventDefaultBranch() or readRemoteHead()
end

return resolveBaseBranch
