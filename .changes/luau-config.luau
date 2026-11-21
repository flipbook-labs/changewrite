return {
	bump = "minor",
	category = "Features",
	kind = "cli",
	flags = { "breaking" },
	summary = "Changewrite reads its settings from `changewrite.luau` instead of `changewrite.toml`.",
	description = table.concat({
		"Run `changewrite check --fix` to convert an existing `changewrite.toml`.",
		"Settings are now camelCase, so `unreleased_changes` becomes `unreleasedChanges` and `max_summary_length` becomes `maxSummaryLength`.",
	}, "\n\n"),
}
