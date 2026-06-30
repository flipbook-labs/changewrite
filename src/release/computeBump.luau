local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

-- How the bump levels compare: a release that contains even one `major` entry
-- bumps the major, and `minor` similarly beats `patch`.
local RANK: { [VersionComponent]: number } = {
	patch = 1,
	minor = 2,
	major = 3,
}

-- Combine the bump levels of all pending unreleased changes into the single
-- component the next release should step. Returns nil for an empty set, leaving
-- it to the caller to decide what "nothing to bump" means.
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
