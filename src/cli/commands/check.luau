local cli = require("@batteries/cli")
local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local chomp = require("@root/chomp")
local config = require("@root/config")
local detectAddedEntries = require("@root/release/detectAddedEntries")
local splitLines = require("@root/release/splitLines")
local types = require("@root/cli/types")
local versionSource = require("@root/release/versionSource")

local title = "check"
local summary = "Validate the unreleased changelog entries for the current branch."

local parser = cli.parser()
parser:add("base", "option", {
	help = "Base ref to diff against when detecting a newly added entry. Defaults to the remote's default branch.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

-- git records the remote's default branch as `refs/remotes/origin/HEAD` on
-- clone, so read it rather than assuming `origin/main`.
local function detectDefaultBaseRef(): string?
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
	return if ref ~= "" then ref else nil
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

local function printNoBaseRefError()
	print(richterm.red("Could not determine a base ref to compare against."))
	print("")
	print(richterm.bold("To fix:"))
	print("  • Pass the base branch with --base <ref>.")
	print("  • Or set the remote's default branch (git remote set-head origin --auto).")
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

	local trimmed = chomp(stderr)
	if trimmed ~= "" then
		print("")
		print(richterm.bold("git said:"))
		print(trimmed)
	end
end

-- Entry files that exist only in the working tree, so a local run can confirm a
-- just-created entry before it is committed. On CI the checkout is clean, so
-- these listings come back empty and the committed diff alone decides the run.
local function collectWorkingTreeAdditions(dir: string): { string }
	local paths: { string } = {}

	-- Staged or unstaged additions to tracked files, relative to HEAD.
	local tracked = process.run({
		config.gitCmd,
		"diff",
		"--name-only",
		"--diff-filter=A",
		"HEAD",
		"--",
		dir,
	})
	if tracked.ok then
		for _, line in splitLines(tracked.stdout) do
			table.insert(paths, line)
		end
	end

	-- New files that have not been staged yet, minus anything gitignored.
	local untracked = process.run({
		config.gitCmd,
		"ls-files",
		"--others",
		"--exclude-standard",
		"--",
		dir,
	})
	if untracked.ok then
		for _, line in splitLines(untracked.stdout) do
			table.insert(paths, line)
		end
	end

	return paths
end

local function run()
	local dir = versionSource.getUnreleasedChangesDir()
	local baseRef = parser:get("base") or detectDefaultBaseRef()
	if not baseRef then
		printNoBaseRefError()
		process.exit(1)
	end
	assert(baseRef)

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

	-- Count entries added on the branch and entries that only exist in the
	-- working tree, so `check` passes locally before the entry is committed.
	local candidates = splitLines(diff.stdout)
	for _, line in collectWorkingTreeAdditions(dir) do
		table.insert(candidates, line)
	end

	local addedEntries = detectAddedEntries(candidates, dir)
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
