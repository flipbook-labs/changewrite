local cli = require("@batteries/cli")
local process = require("@std/process")

local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local types = require("@root/cli/types")

local title = "publish"
local summary = "Take the draft GitHub release for a tag live."

-- Printed when the tag can never be published because GitHub reserved it (see
-- below). The release workflow greps for this marker to switch into recovery
-- instead of failing the whole run.
local BURNED_TAG_MARKER = "changewrite::burned-tag"

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

	if view.stdout:gsub("%s+$", "") ~= "true" then
		print(`Release {tag} is already published`)
		return
	end

	-- Flip the draft live. `gh` recomputes the "latest" release from semver on its
	-- own, so we don't force it and any future prerelease stays out of that slot.
	local edit = process.run({ config.ghCmd, "release", "edit", tag, "--draft=false" })
	if edit.ok then
		print(`Published release {tag}`)
		return
	end

	-- GitHub permanently reserves a tag once an immutable release has used it, even
	-- after that release is deleted: publishing a draft tries to create the tag's
	-- ref, which the reservation blocks (HTTP 422, "tag_name was used by an
	-- immutable release"). That tag can never be published, so rather than failing
	-- the run we surface the diagnostics and emit a marker, letting the caller
	-- recover by bumping the release flow onto the next version.
	local details = `{edit.stderr}\n{edit.stdout}`
	if details:find("immutable release") or details:find("creations being restricted") then
		print(details)
		print(`Tag {tag} was reserved by a deleted immutable release and can never be published.`)
		print(BURNED_TAG_MARKER)
		return
	end

	-- Any other failure is a genuine error.
	error(details)
end

local command: types.Command = {
	run = publish,
	title = title,
	summary = summary,
	parser = parser,
}

return command
