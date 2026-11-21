local path = require("@std/path")

local readOptionalString = require("@root/release/readOptionalString")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function parseVersionTarget(value: unknown): VersionTarget?
	if typeof(value) ~= "table" then
		return nil
	end

	local target = value :: { [string]: unknown }
	local file = readOptionalString(target.file)
	if not file then
		return nil
	end

	return {
		file = path.parse(file),
		pattern = readOptionalString(target.pattern),
	}
end

return parseVersionTarget
