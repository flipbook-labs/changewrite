-- Render a starter `changewrite.toml` making it the version authority and
-- mirroring the detected manifests.
local path = require("@std/path")

local constants = require("@root/release/constants")

local function renderInitConfig(version: string, mirrors: { path.Path }): string
	local lines = {
		`categories = ["{table.concat(constants.DEFAULT_CATEGORIES, '", "')}"]`,
		"",
		"[version]",
		`current = "{version}"`,
	}

	if #mirrors > 0 then
		table.insert(lines, "mirror = [")
		for _, file in mirrors do
			table.insert(lines, `  \{ file = "{file}" \},`)
		end
		table.insert(lines, "]")
	end

	return table.concat(lines, "\n") .. "\n"
end

return renderInitConfig
