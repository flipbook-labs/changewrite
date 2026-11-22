return {
	bump = "minor",
	category = "Features",
	kind = "CLI",
	flags = { "Breaking" },
	summary = "Changelog entries are Luau files that return their fields, and `changewrite check` keeps each summary to one short line.",
	body = [[
Run `changewrite check --fix` to convert pending Markdown entries.

Flags are now written `Breaking`, `Deprecated`, and `Security`, so a `[flag.breaking]` table in `changewrite.toml` becomes `[flag.Breaking]`. The conversion fixes the flags in each entry. Chip files keep their lowercase names, so past releases still show their chips.
]],
}
