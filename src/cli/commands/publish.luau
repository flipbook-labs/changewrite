local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.11.1")
local cli = require("@batteries/cli")
local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local types = require("@root/cli/types")

local run = FlipbookBatteries.run

local title = "publish"
local summary = "Take the draft GitHub release for a tag live."

local parser = cli.parser()
parser:add("tag", "option", {
	help = "Release tag to publish (e.g. v1.2.3). Defaults to the configured changewrite version source.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function publish()
	local tag = parser:get("tag") or `v{getCurrentVersion()}`

	-- One call answers both "does the release exist?" (a non-ok exit means it
	-- doesn't) and "is it still a draft?". Publish never creates a release, so a
	-- missing one is an error rather than something to draft here.
	local view = process.run({ config.ghCmd, "release", "view", tag, "--json", "isDraft", "-q", ".isDraft" })
	assert(view.ok, `No release found for {tag}; nothing to publish`)

	if chomp(view.stdout) ~= "true" then
		print(`Release {tag} is already published`)
		return
	end

	-- Flip the draft live. `gh` recomputes the "latest" release from semver on its
	-- own, so we don't force it and any future prerelease stays out of that slot.
	run(config.ghCmd, { "release", "edit", tag, "--draft=false" })
	print(`Published release {tag}`)
end

local command: types.Command = {
	run = publish,
	title = title,
	summary = summary,
	parser = parser,
}

return command
