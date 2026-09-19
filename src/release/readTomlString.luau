local toml = require("@batteries/toml")

local function readTomlString(value: toml.TomlValue?): string?
	return if typeof(value) == "string" then value else nil
end

return readTomlString
