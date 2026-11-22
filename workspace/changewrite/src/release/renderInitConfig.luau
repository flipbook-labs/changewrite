-- Render a starter `changewrite.luau` making it the version authority and
-- mirroring the detected manifests.
local path = require("@std/path")

local constants = require("@root/release/constants")
local renderLuauConfig = require("@root/release/renderLuauConfig")

local function renderInitConfig(version: string, mirrors: { path.Path }): string
	local mirrorTargets: { { file: string } } = {}
	for _, file in mirrors do
		table.insert(mirrorTargets, { file = tostring(file) })
	end

	return renderLuauConfig({
		categories = table.clone(constants.DEFAULT_CATEGORIES),
		version = {
			current = version,
			mirror = if #mirrorTargets > 0 then mirrorTargets else nil,
		},
	})
end

return renderInitConfig
