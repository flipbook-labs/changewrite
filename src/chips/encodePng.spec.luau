local test = require("@std/test")

local encodePng = require("@root/chips/encodePng")

local function onePixel(r: number, g: number, b: number, a: number)
	local pixels = buffer.create(4)
	buffer.writeu8(pixels, 0, r)
	buffer.writeu8(pixels, 1, g)
	buffer.writeu8(pixels, 2, b)
	buffer.writeu8(pixels, 3, a)
	return {
		width = 1,
		height = 1,
		pixels = pixels,
	}
end

test.suite("encodePng", function(suite)
	suite:case("writes a 1x1 RGBA PNG byte for byte", function(assert)
		local png = encodePng(onePixel(255, 0, 0, 255))

		-- The signature, IHDR, IDAT with one stored deflate block holding the
		-- filter byte and pixel, then IEND. CRCs and the Adler-32 were checked
		-- against Python's zlib.
		local expected = "\137PNG\r\n\26\n"
			.. "\0\0\0\13IHDR\0\0\0\1\0\0\0\1\8\6\0\0\0\31\21\196\137"
			.. "\0\0\0\16IDAT\120\1\1\5\0\250\255\0\255\0\0\255\5\0\1\255\250\92\136\209"
			.. "\0\0\0\0IEND\174\66\96\130"
		assert.eq(png, expected)
	end)
end)
