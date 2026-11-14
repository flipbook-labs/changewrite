local flattenPath = require("./flattenPath")
local types = require("./types")

type Path = types.Path

type Crossing = {
	x: number,
	winding: number,
}

-- Each pixel row is sampled on this many evenly spaced lines. Coverage along a
-- line is exact, so this only sets vertical anti-aliasing quality.
local SUBSAMPLES = 16

-- Returns how much of each pixel the path covers, from 0 to 1, row by row.
-- Uses the nonzero fill rule, so a reversed inner contour cuts a hole.
local function rasterizePath(path: Path, width: number, height: number, scale: number): { number }
	local edges = flattenPath(path, scale)
	local coverage = table.create(width * height, 0)

	for row = 0, height - 1 do
		for sample = 0, SUBSAMPLES - 1 do
			local y = row + (sample + 0.5) / SUBSAMPLES

			local crossings: { Crossing } = {}
			for _, edge in edges do
				local top, bottom = math.min(edge.y0, edge.y1), math.max(edge.y0, edge.y1)
				if edge.y0 ~= edge.y1 and y >= top and y < bottom then
					local t = (y - edge.y0) / (edge.y1 - edge.y0)
					table.insert(crossings, {
						x = edge.x0 + t * (edge.x1 - edge.x0),
						winding = if edge.y1 > edge.y0 then 1 else -1,
					})
				end
			end
			table.sort(crossings, function(a: Crossing, b: Crossing)
				return a.x < b.x
			end)

			local winding = 0
			for index, crossing in crossings do
				winding += crossing.winding
				local nextCrossing = crossings[index + 1]
				if winding ~= 0 and nextCrossing then
					local spanStart = math.max(crossing.x, 0)
					local spanEnd = math.min(nextCrossing.x, width)
					local column = math.floor(spanStart)
					while column < spanEnd and column < width do
						local overlap = math.min(spanEnd, column + 1) - math.max(spanStart, column)
						if overlap > 0 then
							local cell = row * width + column + 1
							coverage[cell] += overlap / SUBSAMPLES
						end
						column += 1
					end
				end
			end
		end
	end

	for index, value in coverage do
		coverage[index] = math.min(value, 1)
	end
	return coverage
end

return rasterizePath
