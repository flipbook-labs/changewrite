-- Draws small pill-shaped labels, called chips, as light and dark SVGs plus a
-- PNG fallback, using a bundled font so no font renderer is needed.
local buildChipLayers = require("@self/src/buildChipLayers")
local chipDrawing = require("@self/src/chipDrawing")
local deriveChipPalette = require("@self/src/deriveChipPalette")
local deriveDarkColor = require("@self/src/deriveDarkColor")
local generateChips = require("@self/src/generateChips")
local getChipFont = require("@self/src/getChipFont")
local planChips = require("@self/src/planChips")
local rasterizeChip = require("@self/src/rasterizeChip")
local renderChipSvg = require("@self/src/renderChipSvg")
local types = require("@self/src/types")

export type ByColorMode<T> = types.ByColorMode<T>
export type ChipFile = generateChips.ChipFile
export type ChipFiles = planChips.ChipFiles
export type ChipLayers = types.ChipLayers
export type ChipMetrics = types.ChipMetrics
export type ChipPalette = types.ChipPalette
export type ChipSpec = types.ChipSpec
export type ChipStyle = types.ChipStyle
export type ColorModeName = types.ColorModeName
export type ColorModeStyle = types.ColorModeStyle
export type Paint = types.Paint
export type PlannedChip = planChips.PlannedChip

return {
	buildChipLayers = buildChipLayers,
	chipDrawing = chipDrawing,
	deriveChipPalette = deriveChipPalette,
	deriveDarkColor = deriveDarkColor,
	generateChips = generateChips,
	getChipFont = getChipFont,
	planChips = planChips,
	rasterizeChip = rasterizeChip,
	renderChipSvg = renderChipSvg,
}
