local cli = require("@batteries/cli")
local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")
local types = require("@root/cli/types")

local title = "attach"
local summary = "Upload build artifacts to the draft GitHub release for a tag."

local parser = cli.parser()
parser:add("tag", "option", {
	help = "Release tag to attach files to (e.g. v1.2.3).",
	required = true,
})
parser:add("files", "variadic", {
	help = "Files to upload. Pass after `--files` or as trailing arguments.",
	required = true,
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local tag = parser:get("tag") :: string
	local files = parser:variadics()

	-- Only ever attach to a draft. Once a release is published we don't want to
	-- mutate its assets, and a missing release shouldn't be created here.
	local draft = process.run({ config.ghCmd, "release", "view", tag, "--json", "isDraft", "-q", ".isDraft" })
	if not draft.ok or chomp(draft.stdout) ~= "true" then
		print(`No draft release for {tag}, skipping asset upload`)
		return
	end

	-- Argv array (not a shell string) so filenames with spaces stay intact.
	local args = { config.ghCmd, "release", "upload", tag }
	table.move(files, 1, #files, #args + 1, args)
	-- `--clobber` only overwrites assets whose names collide with the files being
	-- uploaded; any other assets already on the release are left untouched. This
	-- makes re-running the attach step idempotent.
	table.insert(args, "--clobber")
	local upload = process.run(args, { stdio = "inherit" })
	assert(upload.ok, upload.stderr)

	print(`Attached {#files} file(s) to {tag}`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
