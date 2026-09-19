local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")

local function readOptionalVersion(file: string): string?
	local resolved = path.resolve(file)
	local pattern = constants.DEFAULT_PATTERNS[file]
	if not pattern or not fs.exists(resolved) then
		return nil
	end
	local version = fs.readFileToString(resolved):match(pattern)
	return version
end

return readOptionalVersion
