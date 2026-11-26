-- Parses and steps `major.minor.patch` versions.
local VersionComponent = require("@self/src/VersionComponent")
local getNextVersion = require("@self/src/getNextVersion")
local parseVersion = require("@self/src/parseVersion")
local parseVersionComponent = require("@self/src/parseVersionComponent")
local pickHighestVersion = require("@self/src/pickHighestVersion")
local types = require("@self/src/types")

export type VersionComponent = types.VersionComponent

return {
	getNextVersion = getNextVersion,
	parseVersion = parseVersion,
	parseVersionComponent = parseVersionComponent,
	pickHighestVersion = pickHighestVersion,
	VersionComponent = VersionComponent,
}
