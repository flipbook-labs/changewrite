local semverTypes = require("@root/semver/types")

type VersionComponent = semverTypes.VersionComponent

export type ParsedUnreleasedChange = {
	bump: VersionComponent,
	category: string,
	body: string,
}

export type UnreleasedChange = ParsedUnreleasedChange & {
	file: string,
}

export type VersionTarget = {
	file: string,
	pattern: string?,
}

export type VersionConfig = {
	current: string?,
	source: VersionTarget,
	mirrors: { VersionTarget },
	unreleasedChangesDir: string,
}

return nil
