-- The part of a `major.minor.patch` version that a release steps.
export type VersionComponent = "major" | "minor" | "patch"

local VersionComponent = table.freeze({
	Major = "major" :: VersionComponent,
	Minor = "minor" :: VersionComponent,
	Patch = "patch" :: VersionComponent,
})

return VersionComponent
