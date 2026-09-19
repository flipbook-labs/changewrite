local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")

local function readOptionalVersion(file: path.Path): string?
	local pattern = constants.DEFAULT_PATTERNS[tostring(file)]
	if not pattern or not fs.exists(file) then
		return nil
	end
	local version = fs.readFileToString(file):match(pattern)
	return version
end

return readOptionalVersion
