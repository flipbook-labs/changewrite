local types = require("@root/release/types")

type VersionComponent = types.VersionComponent

local RANK: { [VersionComponent]: number } = {
	patch = 1,
	minor = 2,
	major = 3,
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
