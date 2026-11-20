local parser = require("@std/syntax/parser")
local path = require("@std/path")

local descriptionString = require("./rules/descriptionString")
local summaryLength = require("./rules/summaryLength")
local summaryString = require("./rules/summaryString")
local types = require("./types")

local RULES: { types.LintRule } = {
	summaryLength,
	summaryString,
	descriptionString,
}

-- Runs every entry rule over one entry. Each rule gets its `options` from
-- `ruleconfigs` and is skipped when it's `off`, as under `lute lint`, so the
-- two report the same violations.
local function runEntryRules(
	source: string,
	sourcepath: path.Path?,
	ruleConfigs: { [string]: types.RuleConfig }?
): { types.LintViolation }
	local cst = parser.parseBlock(source)
	local violations: { types.LintViolation } = {}
	for _, rule in RULES do
		local config = if ruleConfigs then ruleConfigs[rule.name] else nil
		if config and config.off then
			continue
		end
		local context: types.RuleContext = {
			globals = {},
			options = if config and config.options then config.options else {},
		}
		for _, violation in rule.lint(cst, sourcepath, context) do
			table.insert(violations, violation)
		end
	end
	return violations
end

return runEntryRules
