-- These mirror the types `lute lint` expects a rule to return. Lute defines
-- them under its own `@lint` alias, but that alias only resolves inside Lute's
-- bundled rules, so a rule loaded from this package can't require it.

local path = require("@std/path")
local syntax = require("@std/syntax")

-- Lute compares severities as these exact strings, so this stays a union of
-- them rather than `string`.
export type Severity = "error" | "warning" | "info" | "hint"

export type LintViolation = {
	lintname: string,
	location: syntax.Span,
	message: string,
	severity: Severity,
	sourcepath: path.Path?,
}

export type RuleContext = {
	globals: { [string]: unknown },
	options: { [string]: unknown },
}

export type LintRule = {
	read name: string,
	read lint: (cst: syntax.CstStatBlock, sourcepath: path.Path?, context: RuleContext) -> { LintViolation },
}

-- One rule's entry under `lute.lint.ruleconfigs` in `.config.luau`.
export type RuleConfig = {
	off: boolean?,
	options: { [string]: unknown }?,
}

return nil
