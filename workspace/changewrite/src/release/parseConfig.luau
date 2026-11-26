local runSandboxed = require("@root/runSandboxed")
local types = require("@root/release/types")
local validateConfigFields = require("@root/release/validateConfigFields")

type Config = types.Config

--[[
	changewrite.luau returns the config as a table. Like a changelog entry, it
	runs with only the globals `runSandboxed` allows, so a value can be computed
	from a local, such as a color shared by several kinds, but the file can't
	require other modules. This checks the names of the settings and of the
	fields in `release` and `version`. The chip parser checks `kind` and `flag`.
]]
local function parseConfig(source: string): Config
	local value = runSandboxed(source, "changewrite.luau")
	assert(typeof(value) == "table", "changewrite.luau must return a table of settings")
	for name in value :: { [unknown]: unknown } do
		assert(typeof(name) == "string", "changewrite.luau settings must be written as `name = value`")
	end

	local config = value :: Config
	validateConfigFields(config)
	return config
end

return parseConfig
