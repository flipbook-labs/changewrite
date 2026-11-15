local crypto = require("@lute/crypto")

local chipDrawing = require("@root/chips/chipDrawing")
local deriveChipPalette = require("@root/chips/deriveChipPalette")
local types = require("@root/chips/types")

type ChipPalette = types.ChipPalette
type ChipSpec = types.ChipSpec
type ChipStyle = types.ChipStyle

export type ChipFiles = {
	light: string,
	dark: string,
	fallback: string,
}

export type PlannedChip = {
	-- `kind/<name>` or `flag/<name>`, as the lockfile and renderer look it up.
	key: string,
	text: string,
	hash: string,
	files: ChipFiles,
	spec: ChipSpec,
}

local function describePalette(palette: ChipPalette): string
	local parts: { string } = {}
	for _, layer in { "tint", "rim", "dot", "text" } do
		local paint = (palette :: any)[layer]
		table.insert(parts, `{layer}={paint.color}@{paint.opacity}`)
	end
	return table.concat(parts, ";")
end

local function describeMetrics(): string
	local metrics = chipDrawing.metrics
	return table.concat({
		metrics.height,
		metrics.rimWidth,
		metrics.paddingLeft,
		metrics.dotDiameter,
		metrics.dotGap,
		metrics.paddingRight,
		metrics.fontSize,
		metrics.letterSpacing,
	}, ",")
end

-- A short hash of everything that decides how a chip looks. It goes in the
-- chip's filenames, because GitHub serves images in release notes through a
-- proxy that caches each URL for a long time. A restyled chip needs a URL the
-- proxy hasn't seen.
local function hashChip(text: string, palettes: types.ByColorMode<ChipPalette>): string
	local description = table.concat({
		`style={chipDrawing.styleVersion}`,
		`png={chipDrawing.pngScale}`,
		`metrics={describeMetrics()}`,
		`text={text}`,
		`light={describePalette(palettes.light)}`,
		`dark={describePalette(palettes.dark)}`,
	}, "\n")
	local digest = crypto.digest(crypto.hash.sha256, description)
	local hex: { string } = {}
	for index = 0, 3 do
		table.insert(hex, string.format("%02x", buffer.readu8(digest, index)))
	end
	return table.concat(hex)
end

-- Works out each chip's palettes, hash, and filenames, without drawing it.
local function planChips(styles: { ChipStyle }): { PlannedChip }
	local planned: { PlannedChip } = {}
	for _, style in styles do
		local palettes = {
			light = deriveChipPalette("light", style.colorMode.light),
			dark = deriveChipPalette("dark", style.colorMode.dark),
		}
		local hash = hashChip(style.text, palettes)
		local stem = `{style.group}-{style.name}-{hash}`
		table.insert(planned, {
			key = `{style.group}/{style.name}`,
			text = style.text,
			hash = hash,
			files = {
				light = `{stem}-light.svg`,
				dark = `{stem}-dark.svg`,
				fallback = `{stem}-light.png`,
			},
			spec = {
				name = stem,
				label = style.text,
				colorMode = palettes,
			},
		})
	end
	return planned
end

return planChips
