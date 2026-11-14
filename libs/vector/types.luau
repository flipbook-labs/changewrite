-- Coordinates are in pixels with y pointing down, the convention SVG uses.
export type PathCommand =
	{ op: "M", x: number, y: number }
	| { op: "L", x: number, y: number }
	| { op: "Q", x1: number, y1: number, x: number, y: number }
	| { op: "C", x1: number, y1: number, x2: number, y2: number, x: number, y: number }
	| { op: "Z" }

export type Path = { PathCommand }

-- A straight line segment, as paths are flattened to for rasterizing.
export type Edge = {
	x0: number,
	y0: number,
	x1: number,
	y1: number,
}

-- Channels from 0 to 1, with straight (not premultiplied) alpha.
export type Color = {
	r: number,
	g: number,
	b: number,
	a: number,
}

return nil
