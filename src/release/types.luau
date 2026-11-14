local path = require("@std/path")

local semverTypes = require("@root/semver/types")

type VersionComponent = semverTypes.VersionComponent

export type ChangeKind = "new" | "improved" | "fixed" | "breaking"

export type ChangeFlag = "api" | "deprecated" | "security"

export type ParsedUnreleasedChange = {
	bump: VersionComponent,
	category: string,
	body: string,
	kind: ChangeKind?,
	flags: { ChangeFlag },
	highlight: string?,
	pr: number?,
}

export type UnreleasedChange = ParsedUnreleasedChange & {
	file: path.Path,
}

export type ReleaseSummary = {
	file: path.Path,
	name: string?,
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
