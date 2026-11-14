-- Chips are hosted images rather than inline styling, because GitHub strips
-- CSS from release notes. Each version of the artwork lives in its own folder,
-- since GitHub's image proxy caches a URL long after the file behind it changes.
local CHIP_BASE_URL = "https://raw.githubusercontent.com/flipbook-labs/changewrite/main/assets/chips/v1"

local function renderChip(name: string): string
	local label = name:upper()
	return table.concat({
		"<picture>",
		`<source media="(prefers-color-scheme: dark)" srcset="{CHIP_BASE_URL}/{name}-dark.svg">`,
		`<source media="(prefers-color-scheme: light)" srcset="{CHIP_BASE_URL}/{name}-light.svg">`,
		`<img src="{CHIP_BASE_URL}/{name}-light.png" alt="{label}" height="18" align="texttop">`,
		"</picture>",
	})
end

return renderChip
