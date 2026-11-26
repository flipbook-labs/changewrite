local path = require("@std/path")
local semver = require("@workspace/semver")

type VersionComponent = semver.VersionComponent

-- changewrite.luau's table, as the file returned it. `validateConfigFields`
-- checks its field names, and each parse module reads and checks one setting.
export type Config = { [string]: unknown }

export type ChangeFlag = "Breaking" | "Deprecated" | "Security"

export type ParsedUnreleasedChange = {
	bump: VersionComponent,
	category: string,
	summary: string,
	body: string?,
	kind: string?,
	flags: { ChangeFlag },
	highlight: string?,
	pr: number?,
}

export type UnreleasedChange = ParsedUnreleasedChange & {
	file: path.Path,
}

-- Something wrong with one entry file, and the file it's in.
export type EntryProblem = {
	file: path.Path,
	problem: string,
}

export type ParsedEntryFiles = {
	changes: { UnreleasedChange },
	problems: { EntryProblem },
}

export type ReleaseSummary = {
	file: path.Path,
	tldr: string,
}

export type VersionTarget = {
	file: path.Path,
	pattern: string?,
}

export type VersionConfig = {
	current: string?,
	source: VersionTarget,
	mirrors: { VersionTarget },
	unreleasedChangesDir: path.Path,
}

return nil
