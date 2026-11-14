local vector = require("@libs/vector")

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
