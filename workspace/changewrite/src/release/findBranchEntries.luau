local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")
local detectAddedEntries = require("@root/release/detectAddedEntries")
local getPullRequestHeadSha = require("@root/release/getPullRequestHeadSha")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local readGithubEvent = require("@root/release/readGithubEvent")
local splitLines = require("@root/release/splitLines")

export type BranchEntries = {
	-- The entry files the branch adds, as paths git reports them.
	entries: { string },
	-- What git said when it couldn't compare the branch against the base ref.
	-- `entries` is empty when this is set.
	err: string?,
}

-- Entry files that exist only in the working tree, so a local run can confirm a
-- just-created entry before it is committed. On CI the checkout is clean, so
-- these listings come back empty and the committed diff alone decides the run.
local function collectWorkingTreeAdditions(dir: path.Path): { string }
	local paths: { string } = {}

	-- New files staged against HEAD but not yet committed. A brand-new file only
	-- shows here once it is tracked; while still untracked it is caught below.
	local tracked = process.run({
		config.gitCmd,
		"diff",
		"--name-only",
		"--diff-filter=A",
		"HEAD",
		"--",
		tostring(dir),
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
		tostring(dir),
	})
	if untracked.ok then
		for _, line in splitLines(untracked.stdout) do
			table.insert(paths, line)
		end
	end

	return paths
end

--[[
	Files that commits on the base branch added and the branch's tip, `head`,
	doesn't have yet. These are left out of the entries the branch adds.

	They matter in a stack of pull requests. A child branch starts from its
	parent's branch and carries the parent's commits. When the parent merges,
	GitHub retargets the child to the parent's base. A merge commit makes the
	parent's commits part of the base, so the diff above already leaves the
	parent's entry out. A squash or rebase merge puts new copies of them on the base instead.
	Until the child merges that base in, its merge-base with the base is from
	before the parent, so the diff above shows the parent's entry as added on
	the child. The copy on the base added that same path, so it shows up here
	and is left out.

	The same holds once the parent's entry is released and deleted from the
	base. On a pull request, `HEAD` is a merge of the head into the base, which
	brings the child's copy of that entry back. The merge already contains the
	base, so the range has to start from the branch's tip rather than `HEAD`.

	If git can't list them, nothing is left out and the branch is counted as
	the diff alone reports it.
]]
local function collectBaseAdditions(baseRef: string, head: string, dir: path.Path): { [string]: true }
	local result = process.run({
		config.gitCmd,
		"log",
		"--format=",
		"--name-only",
		"--diff-filter=A",
		`{head}..{baseRef}`,
		"--",
		tostring(dir),
	})
	local files: { [string]: true } = {}
	if result.ok then
		for _, line in splitLines(result.stdout) do
			files[line] = true
		end
	end
	return files
end

-- The entry files the current branch adds compared to `baseRef`, counting
-- entries that are committed, staged, or only in the working tree.
local function findBranchEntries(baseRef: string): BranchEntries
	local dir = getUnreleasedChangesDir()

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
		tostring(dir),
	})
	if not diff.ok then
		return {
			entries = {},
			err = diff.stderr,
		}
	end

	local candidates = splitLines(diff.stdout)
	for _, line in collectWorkingTreeAdditions(dir) do
		table.insert(candidates, line)
	end

	local head = getPullRequestHeadSha(readGithubEvent()) or "HEAD"
	local baseAdditions = collectBaseAdditions(baseRef, head, dir)
	local entries: { string } = {}
	for _, entry in detectAddedEntries(candidates, dir) do
		if not baseAdditions[entry] then
			table.insert(entries, entry)
		end
	end
	return {
		entries = entries,
	}
end

return findBranchEntries
