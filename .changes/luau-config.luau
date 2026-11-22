return {
	bump = "minor",
	category = "Features",
	kind = "CLI",
	flags = { "Breaking" },
	summary = "Changewrite reads its settings from `changewrite.luau` instead of `changewrite.toml`.",
	body = table.concat({
		"Run `changewrite check --fix` to convert an existing `changewrite.toml`.",
		"Settings are now camelCase, so `unreleased_changes` becomes `unreleasedChanges` and `max_summary_length` becomes `maxSummaryLength`.",
		"A version mirror in a subfolder, such as `workspace/png/pkg.luau`, now gets its file's default pattern, so it no longer needs its own `pattern`.",
	}, "\n\n"),
}
