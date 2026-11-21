-- 2D vector paths: building shapes, writing them as SVG path data, and
-- rasterizing them onto an anti-aliased RGBA canvas.
local createCanvas = require("@self/src/createCanvas")
local flattenPath = require("@self/src/flattenPath")
local formatNumber = require("@self/src/formatNumber")
local parseHexColor = require("@self/src/parseHexColor")
local pathToSvgData = require("@self/src/pathToSvgData")
local pillPath = require("@self/src/pillPath")
local rasterizePath = require("@self/src/rasterizePath")
local types = require("@self/src/types")

export type Canvas = createCanvas.Canvas
export type Color = types.Color
export type Edge = types.Edge
export type Path = types.Path
export type PathCommand = types.PathCommand

return {
	createCanvas = createCanvas,
	flattenPath = flattenPath,
	formatNumber = formatNumber,
	parseHexColor = parseHexColor,
	pathToSvgData = pathToSvgData,
	pillPath = pillPath,
	rasterizePath = rasterizePath,
}
