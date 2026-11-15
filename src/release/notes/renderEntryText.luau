local notesTypes = require("@root/release/notes/types")
local renderChips = require("@root/release/notes/renderChips")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- The text of one list item: chips, then the entry's body (or only its
-- highlight title, where the full body is shown elsewhere in the notes), then
-- its pull request.
local function renderEntryText(entry: UnreleasedChange, context: notesTypes.NotesContext, isTitleOnly: boolean): string
	local text = if isTitleOnly and entry.highlight then entry.highlight else entry.body

	local chips = renderChips(entry, context.chips)
	if chips ~= "" then
		text = `{chips} {text}`
	end
	if entry.pr then
		text ..= ` ({renderPullRequestLink(entry.pr, context.repositoryUrl)})`
	end
	return text
end

return renderEntryText
