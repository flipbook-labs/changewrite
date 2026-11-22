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
--
-- The filenames use the name in lowercase, such as `flag-breaking-light.svg`
-- for the `Breaking` flag, while the key keeps the name as written. Flags and
-- many repos' kinds used to be lowercase, and published releases link to
-- files named that way, so lowercasing keeps those links working after a
-- rename such as `breaking` to `Breaking`. parseChipStyles rejects kinds whose
-- names differ only in case, and flag names are fixed, so no two chips share a
-- filename.
local function planChips(styles: { ChipStyle }): { PlannedChip }
	local planned: { PlannedChip } = {}
	for _, style in styles do
		local stem = `{style.group}-{style.name:lower()}`
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
