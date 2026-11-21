local vector = require("@vector")

type Path = vector.Path

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

export type ColorModeName = "light" | "dark"

-- What a chip is drawn with in each color mode, so GitHub can show the one
-- that matches the viewer's.
export type ByColorMode<T> = {
	light: T,
	dark: T,
}

export type ChipSpec = {
	name: string,
	label: string,
	colorMode: ByColorMode<ChipPalette>,
}

export type ColorModeStyle = {
	color: string,
	textColor: string?,
}

-- A chip before its colors are worked out. Chips are named by a group and a
-- name, such as Changewrite's `kind/notes` or `flag/breaking`, so two groups can
-- reuse a name.
export type ChipStyle = {
	group: string,
	name: string,
	text: string,
	colorMode: ByColorMode<ColorModeStyle>,
}

export type ChipMetrics = {
	read height: number,
	read rimWidth: number,
	read paddingLeft: number,
	read dotDiameter: number,
	read dotGap: number,
	read paddingRight: number,
	read fontSize: number,
	read letterSpacing: number,
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
