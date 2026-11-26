return {
	bump = "minor",
	category = "Changes",
	flags = { "Breaking" },
	kind = "CLI",
	summary = "`changewrite check` fails a branch that adds more than one entry. Set `maxEntriesPerPullRequest` to change the limit.",
	body = "In a stack of pull requests, a parent's entry stops counting against its child once the parent merges.",
}
