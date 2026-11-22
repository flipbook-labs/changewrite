local deriveChipPalette = require("@root/chips/deriveChipPalette")
local types = require("@root/chips/types")

type ChipSpec = types.ChipSpec
type ChipStyle = types.ChipStyle

export type ChipFiles = {
	light: string,
	dark: string,
	fallback: string,
}

export type PlannedChip = {
	-- `kind/<name>` or `flag/<name>`, the key release notes look a chip up by.
	key: string,
	text: string,
	files: ChipFiles,
	spec: ChipSpec,
}

-- Works out each chip's light and dark colors and its filenames, without
-- drawing it. A chip's filenames come from its group (`kind` or `flag`) and
-- name alone, so restyling it rewrites the same files and every release that
-- links to them shows the new look.
local function planChips(styles: { ChipStyle }): { PlannedChip }
	local planned: { PlannedChip } = {}
	for _, style in styles do
		local stem = `{style.group}-{style.name}`
		table.insert(planned, {
			key = `{style.group}/{style.name}`,
			text = style.text,
			files = {
				light = `{stem}-light.svg`,
				dark = `{stem}-dark.svg`,
				fallback = `{stem}-light.png`,
			},
			spec = {
				name = stem,
				label = style.text,
				colorMode = {
					light = deriveChipPalette("light", style.colorMode.light),
					dark = deriveChipPalette("dark", style.colorMode.dark),
				},
			},
		})
	end
	return planned
end

return planChips
