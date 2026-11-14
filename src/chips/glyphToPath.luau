local types = require("@root/chips/types")

type Glyph = types.Glyph
type GlyphPoint = types.GlyphPoint
type Path = types.Path

-- Converts a glyph's TrueType outline to quadratic path commands. TrueType
-- leaves an on-curve point implied halfway between two consecutive off-curve
-- points, so those midpoints are filled in here.
local function glyphToPath(glyph: Glyph, originX: number, baselineY: number, scale: number): Path
	local path: Path = {}

	local function toX(point: GlyphPoint): number
		return originX + point.x * scale
	end
	local function toY(point: GlyphPoint): number
		return baselineY - point.y * scale
	end

	for _, contour in glyph.contours do
		local count = #contour
		if count == 0 then
			continue
		end

		-- Start from an on-curve point. When there is none, start from the
		-- implied midpoint between the first two points.
		local startIndex = 1
		while startIndex <= count and not contour[startIndex].isOnCurve do
			startIndex += 1
		end

		local points: { GlyphPoint } = {}
		if startIndex <= count then
			for offset = 0, count - 1 do
				table.insert(points, contour[(startIndex - 1 + offset) % count + 1])
			end
		else
			local a, b = contour[1], contour[2] or contour[1]
			table.insert(points, {
				x = (a.x + b.x) / 2,
				y = (a.y + b.y) / 2,
				isOnCurve = true,
			})
			for index = 2, count do
				table.insert(points, contour[index])
			end
			table.insert(points, a)
		end

		local first = points[1]
		table.insert(path, { op = "M" :: "M", x = toX(first), y = toY(first) })

		local control: GlyphPoint? = nil
		for index = 2, #points + 1 do
			local point = if index <= #points then points[index] else first
			if point.isOnCurve then
				if control then
					table.insert(path, {
						op = "Q" :: "Q",
						x1 = toX(control),
						y1 = toY(control),
						x = toX(point),
						y = toY(point),
					})
					control = nil
				else
					table.insert(path, { op = "L" :: "L", x = toX(point), y = toY(point) })
				end
			else
				if control then
					local midpoint: GlyphPoint = {
						x = (control.x + point.x) / 2,
						y = (control.y + point.y) / 2,
						isOnCurve = true,
					}
					table.insert(path, {
						op = "Q" :: "Q",
						x1 = toX(control),
						y1 = toY(control),
						x = toX(midpoint),
						y = toY(midpoint),
					})
				end
				control = point
			end
		end
		table.insert(path, { op = "Z" :: "Z" })
	end

	return path
end

return glyphToPath
