local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")

-- Pull request links need the repository's web URL. GitHub Actions provides it
-- directly. Elsewhere it comes from the `origin` remote, in either its HTTPS or
-- SSH form.
local function getRepositoryUrl(): string?
	local server = process.env.GITHUB_SERVER_URL
	local repository = process.env.GITHUB_REPOSITORY
	if server and server ~= "" and repository and repository ~= "" then
		return `{server}/{repository}`
	end

	local result = process.run({ config.gitCmd, "remote", "get-url", "origin" })
	if not result.ok then
		return nil
	end

	local remote = chomp(result.stdout)
	local slug = remote:match("github%.com[:/](.-)%.git$") or remote:match("github%.com[:/](.-)/?$")
	if slug == nil or slug == "" then
		return nil
	end
	return `https://github.com/{slug}`
end

return getRepositoryUrl
