return {
	bump = "minor",
	category = "Features",
	kind = "cli",
	flags = { "breaking" },
	summary = "Changelog entries are Luau files that return their fields, and `changewrite check` keeps each summary to one short line.",
	description = [[
Run `changewrite check --fix` to convert pending Markdown entries.
]],
}
