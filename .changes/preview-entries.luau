return {
	bump = "minor",
	category = "Features",
	kind = "CLI",
	summary = "Add `changewrite preview`, which shows how a branch's changelog entries will read in the next release.",
	body = "The preview shows the sections the entries land in, with the entries around them, and cuts the rest. To post it on each pull request and keep it current as the branch changes, set the action's `preview-comment` input.",
}
