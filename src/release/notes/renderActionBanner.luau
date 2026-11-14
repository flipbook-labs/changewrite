local ChangeFlag = require("@root/release/ChangeFlag")
local ChangeKind = require("@root/release/ChangeKind")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- Only a release that asks something of the reader gets a banner. One that
-- needs nothing renders none, so the banner never becomes noise to skip.
local function renderActionBanner(entries: { UnreleasedChange }): string?
	local hasBreaking = false
	local hasSecurity = false
	for _, entry in entries do
		if entry.kind == ChangeKind.Breaking then
			hasBreaking = true
		end
		if table.find(entry.flags, ChangeFlag.Security) then
			hasSecurity = true
		end
	end

	if hasBreaking then
		local lines = {
			"> [!WARNING]",
			"> Action required: this release has breaking changes. Each one under [Breaking changes](#breaking-changes) says what changed.",
		}
		if hasSecurity then
			table.insert(lines, ">")
			table.insert(lines, "> It also includes security fixes.")
		end
		return table.concat(lines, "\n")
	end
	if hasSecurity then
		return table.concat({
			"> [!IMPORTANT]",
			"> Update recommended: this release includes security fixes.",
		}, "\n")
	end
	return nil
end

return renderActionBanner
