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

-- Outlines converted for drawing, in pixels with y pointing down. TrueType
-- curves are all quadratic, so these are the only commands produced.
export type PathCommand =
	{ op: "M", x: number, y: number }
	| { op: "L", x: number, y: number }
	| { op: "Q", x1: number, y1: number, x: number, y: number }
	| { op: "Z" }

export type Path = { PathCommand }

return nil
