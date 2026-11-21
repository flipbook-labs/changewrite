local path = require("@std/path")

local semverTypes = require("@root/semver/types")

type VersionComponent = semverTypes.VersionComponent

-- changewrite.luau's table, as the file returned it. `validateConfigFields`
-- checks its field names, and each parse module reads and checks one setting.
export type Config = { [string]: unknown }

export type ChangeFlag = "breaking" | "deprecated" | "security"

export type ParsedUnreleasedChange = {
	bump: VersionComponent,
	category: string,
	summary: string,
	body: string,
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
