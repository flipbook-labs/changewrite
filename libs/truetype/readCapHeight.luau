local readI16 = require("./readI16")
local readU16 = require("./readU16")

-- The OS/2 table gained `sCapHeight` in version 2. Older tables end before it,
-- so their cap height comes from `measureCapital` instead.
local function readCapHeight(data: buffer, os2Offset: number, measureCapital: () -> number): number
	local version = readU16(data, os2Offset)
	if version >= 2 then
		return readI16(data, os2Offset + 88)
	end
	return measureCapital()
end

return readCapHeight
