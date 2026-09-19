local path = require("@std/path")

local semverTypes = require("@root/semver/types")

type VersionComponent = semverTypes.VersionComponent

export type ParsedUnreleasedChange = {
	bump: VersionComponent,
	category: string,
	body: string,
}

export type UnreleasedChange = ParsedUnreleasedChange & {
	file: path.Path,
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
