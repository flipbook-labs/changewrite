-- TrueType is big-endian, while `buffer` reads little-endian.
local function readU16(data: buffer, offset: number): number
	return bit32.bor(bit32.lshift(buffer.readu8(data, offset), 8), buffer.readu8(data, offset + 1))
end

return readU16
