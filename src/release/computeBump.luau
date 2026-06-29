local getNextVersion = require("@root/release/getNextVersion")

type VersionComponent = getNextVersion.VersionComponent

-- How the bump levels compare: a release that contains even one `major` entry
-- bumps the major, and `minor` similarly beats `patch`.
local RANK: { [VersionComponent]: number } = {
	patch = 1,
	minor = 2,
	major = 3,
}

-- Combine the bump levels of all pending change partials into the single
-- component the next release should step. Errors on an empty set, since a
-- release with no partials has nothing to bump.
local function computeBump(components: { VersionComponent }): VersionComponent
	local highest: VersionComponent? = nil
	for _, component in components do
		if highest == nil or RANK[component] > RANK[highest] then
			highest = component
		end
	end
	assert(highest, "Cannot compute a bump from an empty set of change partials")
	return highest
end

return computeBump
