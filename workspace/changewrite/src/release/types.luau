local path = require("@std/path")
local semver = require("@workspace/semver")

type VersionComponent = semver.VersionComponent

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
