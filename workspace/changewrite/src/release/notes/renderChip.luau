local chipDrawing = require("@root/chips/chipDrawing")
local planChips = require("@root/chips/planChips")

-- Chips are images rather than inline styling, because GitHub strips CSS from
-- release notes. The viewer's browser picks the light or dark source to match
-- their color mode, and the PNG stands in where SVG isn't shown, such as in
-- notification emails.
--
-- `<source>` and `<img>` close themselves with `/>`. HTML accepts either form,
-- but docs sites such as Moonwave parse CHANGELOG.md as MDX, which fails the
-- build on a tag that isn't closed.
local function renderChip(chip: planChips.PlannedChip, assetsUrl: string): string
	local alt = chip.text:gsub("&", "&amp;"):gsub('"', "&quot;"):gsub("<", "&lt;")
	return table.concat({
		"<picture>",
		`<source media="(prefers-color-scheme: dark)" srcset="{assetsUrl}/{chip.files.dark}" />`,
		`<source media="(prefers-color-scheme: light)" srcset="{assetsUrl}/{chip.files.light}" />`,
		`<img src="{assetsUrl}/{chip.files.fallback}" alt="{alt}" height="{chipDrawing.metrics.height}" align="texttop" />`,
		"</picture>",
	})
end

return renderChip
