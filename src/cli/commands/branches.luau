local cli = require("@batteries/cli")
local json = require("@std/json")

local getDebugBranch = require("@root/release/getDebugBranch")
local readPublishBranch = require("@root/release/readPublishBranch")
local resolveBaseBranch = require("@root/release/resolveBaseBranch")
local types = require("@root/cli/types")

local title = "branches"
local summary = "Print the base and publish branches a release run uses, as JSON."

local parser = cli.parser()
parser:add("base-branch", "option", {
	help = "Use this base branch instead of resolving one. Defaults to the pull request's base branch on GitHub Actions, otherwise the repository's default branch.",
})
parser:add("publish-branch", "option", {
	help = "Use this publish branch instead of `[release] branch` from changewrite.toml.",
})
parser:add("debug", "flag", {
	help = "Print the debug variant of the publish branch.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

-- The action forwards its inputs unconditionally, so an empty value means unset.
local function getOption(name: string): string?
	local value = parser:get(name)
	return if value and value ~= "" then value else nil
end

local function run()
	local base = getOption("base-branch") or resolveBaseBranch()
	assert(base, "Could not determine the base branch. Pass it with --base-branch.")

	local publish = getOption("publish-branch") or readPublishBranch()
	if parser:has("debug") then
		publish = getDebugBranch(publish)
	end

	print(json.serialize({
		base = base,
		publish = publish,
	}))
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
