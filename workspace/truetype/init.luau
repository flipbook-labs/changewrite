-- Reads static TrueType fonts and turns text into outline paths, so text can be
-- drawn without a font renderer.
local layoutText = require("@self/src/layoutText")
local measureText = require("@self/src/measureText")
local readTrueTypeFont = require("@self/src/readTrueTypeFont")
local types = require("@self/src/types")

export type Font = types.Font
export type Glyph = types.Glyph
export type GlyphPoint = types.GlyphPoint
export type Path = types.Path
export type PathCommand = types.PathCommand

return {
	layoutText = layoutText,
	measureText = measureText,
	readTrueTypeFont = readTrueTypeFont,
}
