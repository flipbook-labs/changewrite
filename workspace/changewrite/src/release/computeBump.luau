local semver = require("@workspace/semver")

type VersionComponent = semver.VersionComponent

local RANK: { [VersionComponent]: number } = {
	[semver.VersionComponent.Patch] = 1,
	[semver.VersionComponent.Minor] = 2,
	[semver.VersionComponent.Major] = 3,
}

local function computeBump(components: { VersionComponent }): VersionComponent?
	local highest: VersionComponent? = nil
	for _, component in components do
		if highest == nil or RANK[component] > RANK[highest] then
			highest = component
		end
	end
	return highest
end

return computeBump
