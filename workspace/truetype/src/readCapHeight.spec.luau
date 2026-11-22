local test = require("@std/test")

local readCapHeight = require("./readCapHeight")

-- An OS/2 table long enough to hold `sCapHeight`, with only the version and
-- that field filled in.
local function os2Table(version: number, capHeight: number): buffer
	local data = buffer.create(96)
	buffer.writeu8(data, 0, bit32.rshift(version, 8))
	buffer.writeu8(data, 1, bit32.band(version, 0xFF))
	buffer.writeu8(data, 88, bit32.rshift(capHeight, 8))
	buffer.writeu8(data, 89, bit32.band(capHeight, 0xFF))
	return data
end

test.suite("readCapHeight", function(suite)
	suite:case("reads sCapHeight from a version 2 or later table", function(assert)
		local height = readCapHeight(os2Table(4, 1440), 0, function(): number
			error("should not measure a capital")
		end)

		assert.eq(height, 1440)
	end)

	suite:case("measures a capital when the table predates sCapHeight", function(assert)
		local height = readCapHeight(os2Table(1, 1440), 0, function(): number
			return 700
		end)

		assert.eq(height, 700)
	end)
end)
