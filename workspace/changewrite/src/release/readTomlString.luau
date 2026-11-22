local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

local function readTomlString(value: toml.TomlValue?): string?
	return if typeof(value) == "string" then value else nil
end

return readTomlString
