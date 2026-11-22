local readU16 = require("./readU16")

local function readU32(data: buffer, offset: number): number
	return readU16(data, offset) * 0x10000 + readU16(data, offset + 2)
end

return readU32
