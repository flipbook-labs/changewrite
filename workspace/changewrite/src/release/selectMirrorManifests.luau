local constants = require("@root/release/constants")

-- Picks the manifests `init` mirrors, in `MIRROR_MANIFESTS` order, from the ones
-- present in the project.
local function selectMirrorManifests(present: { string }): { string }
	local selected = {}
	for _, manifest in constants.MIRROR_MANIFESTS do
		local replacement = constants.SUPERSEDED_MANIFESTS[manifest]
		local isSuperseded = replacement ~= nil and table.find(present, replacement) ~= nil
		if table.find(present, manifest) and not isSuperseded then
			table.insert(selected, manifest)
		end
	end
	return selected
end

return selectMirrorManifests
