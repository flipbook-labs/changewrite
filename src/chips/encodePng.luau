local rasterizeChip = require("@root/chips/rasterizeChip")

type Image = rasterizeChip.Image

local SIGNATURE = "\137PNG\r\n\26\n"
-- Deflate's stored blocks hold at most this many bytes each.
local MAX_STORED_BLOCK = 65535

local crcTable: { number } = {}
for index = 0, 255 do
	local value = index
	for _ = 1, 8 do
		if bit32.band(value, 1) ~= 0 then
			value = bit32.bxor(0xEDB88320, bit32.rshift(value, 1))
		else
			value = bit32.rshift(value, 1)
		end
	end
	crcTable[index] = value
end

local function crc32(data: string): number
	local crc = 0xFFFFFFFF
	for index = 1, #data do
		crc = bit32.bxor(crcTable[bit32.band(bit32.bxor(crc, data:byte(index)), 0xFF)], bit32.rshift(crc, 8))
	end
	return bit32.bxor(crc, 0xFFFFFFFF)
end

local function adler32(data: string): number
	local a, b = 1, 0
	for index = 1, #data do
		a = (a + data:byte(index)) % 65521
		b = (b + a) % 65521
	end
	return b * 65536 + a
end

local function u32(value: number): string
	return string.pack(">I4", value)
end

local function chunk(kind: string, data: string): string
	return u32(#data) .. kind .. data .. u32(crc32(kind .. data))
end

-- Encodes an RGBA image as a PNG. The image data uses uncompressed deflate
-- blocks, since Lute has no compression library and chips are small enough
-- that the files stay a few kilobytes.
local function encodePng(image: Image): string
	local rows: { string } = {}
	local rowBytes = image.width * 4
	for row = 0, image.height - 1 do
		-- Each row starts with its filter type, and 0 means unfiltered.
		table.insert(rows, "\0" .. buffer.readstring(image.pixels, row * rowBytes, rowBytes))
	end
	local raw = table.concat(rows)

	local blocks: { string } = { "\120\1" }
	local position = 1
	repeat
		local length = math.min(MAX_STORED_BLOCK, #raw - position + 1)
		local isFinal = position + length > #raw
		table.insert(blocks, string.pack("<BI2I2", if isFinal then 1 else 0, length, bit32.bnot(length) % 0x10000))
		table.insert(blocks, raw:sub(position, position + length - 1))
		position += length
	until position > #raw
	table.insert(blocks, u32(adler32(raw)))

	-- Width, height, 8 bits per channel, color type 6 (RGBA), then default
	-- compression, filtering, and no interlacing.
	local header = u32(image.width) .. u32(image.height) .. string.pack("BBBBB", 8, 6, 0, 0, 0)

	return SIGNATURE .. chunk("IHDR", header) .. chunk("IDAT", table.concat(blocks)) .. chunk("IEND", "")
end

return encodePng
