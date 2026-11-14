-- Coordinates are in pixels with y pointing down, the convention SVG and the
-- rasterizer share.
export type PathCommand =
	{ op: "M", x: number, y: number }
	| { op: "L", x: number, y: number }
	| { op: "Q", x1: number, y1: number, x: number, y: number }
	| { op: "C", x1: number, y1: number, x2: number, y2: number, x: number, y: number }
	| { op: "Z" }

export type Path = { PathCommand }

-- A TrueType outline point, in font units with y pointing up.
export type GlyphPoint = {
	x: number,
	y: number,
	isOnCurve: boolean,
}

export type Glyph = {
	advanceWidth: number,
	contours: { { GlyphPoint } },
}

export type Font = {
	unitsPerEm: number,
	capHeight: number,
	getGlyph: (string) -> Glyph,
}

-- A color with an alpha from 0 to 1.
export type Paint = {
	color: string,
	opacity: number,
}

export type ChipPalette = {
	tint: Paint,
	rim: Paint,
	dot: Paint,
	text: Paint,
}

export type ChipSpec = {
	name: string,
	label: string,
	light: ChipPalette,
	dark: ChipPalette,
}

export type ChipMetrics = {
	height: number,
	rimWidth: number,
	paddingLeft: number,
	dotDiameter: number,
	dotGap: number,
	paddingRight: number,
	fontSize: number,
	letterSpacing: number,
}

-- The shapes that make up one chip, painted in order.
export type ChipLayers = {
	width: number,
	height: number,
	rim: Path,
	tint: Path,
	dot: Path,
	text: Path,
}

return nil
