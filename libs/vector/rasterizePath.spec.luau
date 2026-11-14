local test = require("@std/test")

local rasterizePath = require("./rasterizePath")
local types = require("./types")

type Path = types.Path

local function rectangle(x: number, y: number, width: number, height: number): Path
	return {
		{ op = "M", x = x, y = y },
		{ op = "L", x = x + width, y = y },
		{ op = "L", x = x + width, y = y + height },
		{ op = "L", x = x, y = y + height },
		{ op = "Z" },
	}
end

test.suite("rasterizePath", function(suite)
	suite:case("fully covers pixels inside a shape and leaves the rest empty", function(assert)
		local coverage = rasterizePath(rectangle(0, 0, 1, 1), 2, 1, 1)

		assert.eq(coverage[1], 1)
		assert.eq(coverage[2], 0)
	end)

	suite:case("partly covers a pixel a shape only partly overlaps", function(assert)
		local coverage = rasterizePath(rectangle(0, 0, 0.5, 1), 1, 1, 1)

		assert.eq(coverage[1], 0.5)
	end)

	suite:case("scales the path to the image", function(assert)
		local coverage = rasterizePath(rectangle(0, 0, 1, 1), 2, 2, 2)

		assert.eq(coverage[1], 1)
		assert.eq(coverage[4], 1)
	end)

	suite:case("leaves a hole where an inner contour runs the other way", function(assert)
		local path = rectangle(0, 0, 3, 3)
		-- The same square, counterclockwise, around the middle pixel.
		for _, command in
			{
				{ op = "M", x = 1, y = 1 },
				{ op = "L", x = 1, y = 2 },
				{ op = "L", x = 2, y = 2 },
				{ op = "L", x = 2, y = 1 },
				{ op = "Z" },
			} :: Path
		do
			table.insert(path, command)
		end

		local coverage = rasterizePath(path, 3, 3, 1)

		assert.eq(coverage[5], 0)
		assert.eq(coverage[1], 1)
	end)
end)
