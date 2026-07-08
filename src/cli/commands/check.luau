local cli = require("@batteries/cli")
local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local config = require("@root/config")
local detectAddedEntries = require("@root/release/detectAddedEntries")
local types = require("@root/cli/types")
local versionSource = require("@root/release/versionSource")

local title = "check"
local summary = "Validate that the current branch adds an unreleased changelog entry."

-- The action sets this to the PR's base branch. The origin/main default keeps
-- the command usable when run by hand without --base.
local BASE_REF_ENV = "CHANGEWRITE_BASE_REF"
local DEFAULT_BASE_REF = "origin/main"

local parser = cli.parser()
parser:add("base", "option", {
	help = `Base ref to diff against when detecting a newly added entry. Defaults to ${BASE_REF_ENV} or {DEFAULT_BASE_REF}.`,
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function resolveBaseRef(): string
	return parser:get("base") or process.env[BASE_REF_ENV] or DEFAULT_BASE_REF
end

local function formatChangelogTemplate(): string
	return table.concat({
		"---",
		"bump: patch",
		"category: Fixes",
		"---",
		"",
		"One or two sentences describing the change, written for the changelog.",
	}, "\n")
end

local function printNoChangesError()
	local dir = versionSource.getUnreleasedChangesDir()

	print(richterm.red("A changelog entry is required."))
	print("")
	print(`Add a markdown entry under {richterm.bold(dir)} describing this change:`)
	print("")
	print(richterm.bold("Template:"))
	print(formatChangelogTemplate())
	print("")
	print(richterm.bold("Guide:"))
	print("  • bump (required): major, minor, or patch")
	print("  • category (optional): Features, Fixes, Dependencies, Changes (default)")
	print("  • filename: name after the change (e.g., fix-release-permissions.md)")
	print("  • body: changelog text, one or two sentences")
	print("")
	print(`See {path.join(dir, "README.md")} for details.`)
end

-- The diff needs both the base ref and a common ancestor with HEAD. On CI this
-- usually fails because the checkout is shallow, so point at the concrete fix
-- rather than surfacing git's raw error.
local function printBaseRefError(baseRef: string, stderr: string)
	print(richterm.red(`Could not compare against base ref "{baseRef}".`))
	print("")
	print("This usually means the base ref is missing or the checkout has too little history.")
	print("")
	print(richterm.bold("To fix:"))
	print("  • Check out with full history (actions/checkout: fetch-depth: 0).")
	print(`  • Ensure "{baseRef}" is fetched, or pass a different ref with --base <ref>.`)

	local trimmed = stderr:gsub("%s+$", "")
	if trimmed ~= "" then
		print("")
		print(richterm.bold("git said:"))
		print(trimmed)
	end
end

local function run()
	local dir = versionSource.getUnreleasedChangesDir()
	local baseRef = resolveBaseRef()

	-- Added files between the merge-base of the base ref and HEAD, limited to
	-- the unreleased-changes directory. The three-dot range reports what this
	-- branch added, not what differs from the current base tip.
	local diff = process.run({
		config.gitCmd,
		"diff",
		"--name-only",
		"--diff-filter=A",
		`{baseRef}...HEAD`,
		"--",
		dir,
	})

	if not diff.ok then
		printBaseRefError(baseRef, diff.stderr)
		process.exit(1)
	end

	local addedFiles: { string } = {}
	for line in diff.stdout:gmatch("[^\r\n]+") do
		table.insert(addedFiles, line)
	end

	local addedEntries = detectAddedEntries(addedFiles, dir)
	if #addedEntries == 0 then
		printNoChangesError()
		process.exit(1)
	end

	local noun = if #addedEntries == 1 then "entry" else "entries"
	print(`Found {#addedEntries} new unreleased change {noun} on this branch.`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
