export type PreviewCommentInput = {
	-- The excerpt of the next release's CHANGELOG.md section.
	section: string,
	-- The version the next release gets with the pull request's entries.
	version: string,
	-- The version it would get from the other pending entries alone, or nil
	-- when there are none and the pull request's entries start the release.
	versionWithout: string?,
	-- Whether the pull request's entries are what turn on rich notes.
	switchesToRichNotes: boolean,
}

-- The preview of a pull request's changelog entries, as Markdown.
local function renderPreviewComment(input: PreviewCommentInput): string
	local lines = {
		"# Changelog Preview",
		"",
		"Below is your change in context of next release's changelog. Use this to inform how you write your changelog entry, so it fits well with the others.",
		"",
		"See [Changewrite](https://github.com/flipbook-labs/changewrite) for more.",
	}

	if input.versionWithout and input.versionWithout ~= input.version then
		table.insert(lines, "")
		table.insert(
			lines,
			`This pull request changes the next release from v{input.versionWithout} to v{input.version}.`
		)
	end
	if input.switchesToRichNotes then
		table.insert(lines, "")
		table.insert(lines, "This pull request's entries switch the release from plain notes to rich notes.")
	end

	table.insert(lines, "")
	table.insert(lines, "---")
	table.insert(lines, "")
	table.insert(lines, input.section)
	return table.concat(lines, "\n")
end

return renderPreviewComment
