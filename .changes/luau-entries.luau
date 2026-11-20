local types = require("./types")

local entry: types.Entry = {
	bump = "minor",
	category = "Features",
	kind = "cli",
	flags = { "breaking" },
	summary = "Changelog entries are Luau files, checked by lint rules that `changewrite check` and `lute lint` both run.",
	description = [[
Run `changewrite check --fix` to convert pending Markdown entries and write the `Entry` type they annotate.
]],
}

return entry
