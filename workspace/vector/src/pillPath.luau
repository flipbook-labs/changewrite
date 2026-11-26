local types = require("./types")

type Path = types.Path

-- How far a cubic Bézier's control points sit from its ends to approximate a
-- quarter circle.
local KAPPA = 0.5522847498

--[[
	A rounded rectangle whose ends are full semicircles, drawn with cubic curves
	so SVG and the rasterizer draw the same shape. A square makes a circle.
	Drawing one pill counterclockwise inside a clockwise one cuts a hole under
	the nonzero fill rule, which is how the rim is made.
]]
local function pillPath(x: number, y: number, width: number, height: number, isCounterclockwise: boolean?): Path
	local radius = height / 2
	local handle = radius * KAPPA
	local left = x + radius
	local right = x + width - radius
	local top = y
	local bottom = y + height
	local middle = y + radius
	local farLeft = x
	local farRight = x + width

	if isCounterclockwise then
		return {
			{ op = "M", x = right, y = top },
			{ op = "L", x = left, y = top },
			{
				op = "C",
				x1 = left - handle,
				y1 = top,
				x2 = farLeft,
				y2 = middle - handle,
				x = farLeft,
				y = middle,
			},
			{
				op = "C",
				x1 = farLeft,
				y1 = middle + handle,
				x2 = left - handle,
				y2 = bottom,
				x = left,
				y = bottom,
			},
			{ op = "L", x = right, y = bottom },
			{
				op = "C",
				x1 = right + handle,
				y1 = bottom,
				x2 = farRight,
				y2 = middle + handle,
				x = farRight,
				y = middle,
			},
			{
				op = "C",
				x1 = farRight,
				y1 = middle - handle,
				x2 = right + handle,
				y2 = top,
				x = right,
				y = top,
			},
			{ op = "Z" },
		}
	end

	return {
		{ op = "M", x = left, y = top },
		{ op = "L", x = right, y = top },
		{
			op = "C",
			x1 = right + handle,
			y1 = top,
			x2 = farRight,
			y2 = middle - handle,
			x = farRight,
			y = middle,
		},
		{
			op = "C",
			x1 = farRight,
			y1 = middle + handle,
			x2 = right + handle,
			y2 = bottom,
			x = right,
			y = bottom,
		},
		{ op = "L", x = left, y = bottom },
		{
			op = "C",
			x1 = left - handle,
			y1 = bottom,
			x2 = farLeft,
			y2 = middle + handle,
			x = farLeft,
			y = middle,
		},
		{
			op = "C",
			x1 = farLeft,
			y1 = middle - handle,
			x2 = left - handle,
			y2 = top,
			x = left,
			y = top,
		},
		{ op = "Z" },
	}
end

return pillPath
