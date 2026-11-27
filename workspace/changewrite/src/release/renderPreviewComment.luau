local constants = require("@root/release/constants")

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
		`**Changelog preview:** how this pull request's entries will read in the next release. Other entries and sections are cut, and {constants.EXCERPT_CUT} marks each cut.`,
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
