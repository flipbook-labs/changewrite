local fs = require("@std/fs")
local luau = require("@std/luau")
local path = require("@std/path")

local types = require("@root/entries/types")

local CONFIG_FILE = ".config.luau"

-- Reads `lute.lint.ruleconfigs` from `.config.luau` in the working directory,
-- the same place `lute lint` reads it, so `changewrite check` applies the same
-- options. The config is a Luau module, so this runs it to get the table.
local function readRuleConfigs(): { [string]: types.RuleConfig }
	local configPath = path.resolve(CONFIG_FILE)
	if not fs.exists(configPath) then
		return {}
	end

	local config: unknown = luau.loadModule(configPath)
	local lute = if typeof(config) == "table" then (config :: { [string]: unknown }).lute else nil
	local lint = if typeof(lute) == "table" then (lute :: { [string]: unknown }).lint else nil
	local ruleConfigs = if typeof(lint) == "table" then (lint :: { [string]: unknown }).ruleconfigs else nil
	if typeof(ruleConfigs) ~= "table" then
		return {}
	end
	return ruleConfigs :: { [string]: types.RuleConfig }
end

return readRuleConfigs
