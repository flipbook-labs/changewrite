local path = require("@std/path")
local toml = require("@batteries/toml")

local readTomlString = require("@root/release/readTomlString")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function parseVersionTarget(value: toml.TomlValue): VersionTarget?
	if typeof(value) ~= "table" then
		return nil
	end

	local target = value :: { [string]: toml.TomlValue }
	local file = readTomlString(target.file)
	if not file then
		return nil
	end

	return {
		file = path.parse(file),
		pattern = readTomlString(target.pattern),
	}
end

return parseVersionTarget
