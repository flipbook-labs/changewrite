local readU16 = require("./readU16")

local function readI16(data: buffer, offset: number): number
	local value = readU16(data, offset)
	return if value >= 0x8000 then value - 0x10000 else value
end

return readI16
