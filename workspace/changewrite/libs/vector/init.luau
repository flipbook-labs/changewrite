-- 2D vector paths: building shapes, writing them as SVG path data, and
-- rasterizing them onto an anti-aliased RGBA canvas.
local createCanvas = require("@self/createCanvas")
local flattenPath = require("@self/flattenPath")
local formatNumber = require("@self/formatNumber")
local parseHexColor = require("@self/parseHexColor")
local pathToSvgData = require("@self/pathToSvgData")
local pillPath = require("@self/pillPath")
local rasterizePath = require("@self/rasterizePath")
local types = require("@self/types")

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
