-- Render a starter `changewrite.toml` making it the version authority and
-- mirroring the detected manifests.
local function renderInitConfig(version: string, mirrors: { string }): string
	local lines = { "[version]", `current = "{version}"` }

	if #mirrors > 0 then
		table.insert(lines, "mirror = [")
		for _, file in mirrors do
			table.insert(lines, '  { file = "' .. file .. '" },')
		end
		table.insert(lines, "]")
	end

	return table.concat(lines, "\n") .. "\n"
end

return renderInitConfig
