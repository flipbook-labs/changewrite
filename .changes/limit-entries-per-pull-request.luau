return {
	bump = "minor",
	category = "Changes",
	flags = { "Breaking" },
	kind = "CLI",
	summary = "`changewrite check` fails a branch that adds more than one entry. Set `maxEntriesPerPullRequest` to change the limit.",
	body = "An entry the base branch added after the branch forked, such as a squash-merged parent's in a stack of pull requests, doesn't count as the branch's own.",
}
