local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")

-- Render the Markdown notes for a single release: the body that goes on the
-- GitHub release, and the preview shown in the publish PR. Centralising this
-- keeps the two in lockstep — the PR preview is produced by the exact command
-- that later populates the release.
local function renderReleaseNotes(tag: string): string
	-- `--latest` renders the newest *tagged* release's section, which is what we
	-- want once `draft` has created the tag. Before the tag exists (previewing in
	-- the publish PR) those commits are still unreleased, so render them under the
	-- prospective tag instead. `rev-parse --verify` exits non-zero when the ref is
	-- missing; `-q` silences the stderr it would otherwise print.
	local tagExists = process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/{tag}` }).ok

	local args = { config.gitCliffCmd, "--config", "cliff.toml", "--strip", "header" }
	if tagExists then
		table.insert(args, "--latest")
	else
		table.insert(args, "--unreleased")
		table.insert(args, "--tag")
		table.insert(args, tag)
	end

	local notes = process.run(args)
	assert(notes.ok, notes.stderr)

	-- Trim trailing whitespace so callers control the surrounding layout.
	return chomp(notes.stdout)
end

return renderReleaseNotes
