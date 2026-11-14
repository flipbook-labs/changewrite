local types = require("@root/release/types")

type ReleaseSummary = types.ReleaseSummary

-- The section heading has to stay a bare `## v<version>`, so the name travels
-- in a comment that GitHub doesn't display. `draft` reads it back with
-- extractReleaseName to title the release.
local function renderReleaseName(summary: ReleaseSummary): string?
	if summary.name == nil then
		return nil
	end
	return `<!-- release-name: {summary.name} -->`
end

return renderReleaseName
