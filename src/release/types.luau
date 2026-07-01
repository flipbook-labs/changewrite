export type VersionComponent = "major" | "minor" | "patch"

export type ParsedUnreleasedChange = {
	bump: VersionComponent,
	category: string,
	body: string,
}

export type UnreleasedChange = ParsedUnreleasedChange & {
	file: string,
}

return nil
