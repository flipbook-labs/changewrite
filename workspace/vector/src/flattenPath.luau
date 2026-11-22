local types = require("./types")

type Edge = types.Edge
type Path = types.Path

-- Fixed step counts, rather than ones picked from curve length, keep the output
-- identical from run to run. For shapes a few dozen pixels across, these are
-- finer than a pixel.
local QUADRATIC_STEPS = 8
local CUBIC_STEPS = 12

-- Turns a path into straight edges, with coordinates multiplied by `scale`.
local function flattenPath(path: Path, scale: number): { Edge }
	local edges: { Edge } = {}
	local startX, startY = 0, 0
	local x, y = 0, 0

	local function lineTo(nextX: number, nextY: number)
		table.insert(edges, {
			x0 = x * scale,
			y0 = y * scale,
			x1 = nextX * scale,
			y1 = nextY * scale,
		})
		x, y = nextX, nextY
	end

	for _, command in path do
		if command.op == "M" then
			x, y = command.x, command.y
			startX, startY = x, y
		elseif command.op == "L" then
			lineTo(command.x, command.y)
		elseif command.op == "Q" then
			local fromX, fromY = x, y
			for step = 1, QUADRATIC_STEPS do
				local t = step / QUADRATIC_STEPS
				local u = 1 - t
				lineTo(
					u * u * fromX + 2 * u * t * command.x1 + t * t * command.x,
					u * u * fromY + 2 * u * t * command.y1 + t * t * command.y
				)
			end
		elseif command.op == "C" then
			local fromX, fromY = x, y
			for step = 1, CUBIC_STEPS do
				local t = step / CUBIC_STEPS
				local u = 1 - t
				lineTo(
					u * u * u * fromX + 3 * u * u * t * command.x1 + 3 * u * t * t * command.x2 + t * t * t * command.x,
					u * u * u * fromY + 3 * u * u * t * command.y1 + 3 * u * t * t * command.y2 + t * t * t * command.y
				)
			end
		else
			lineTo(startX, startY)
		end
	end
	return edges
end

return flattenPath
