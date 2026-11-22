local notesTypes = require("@root/release/notes/types")
local renderBullet = require("@root/release/renderBullet")
local renderChips = require("@root/release/notes/renderChips")
local renderCollapsedBody = require("@root/release/renderCollapsedBody")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- One entry in a category: chips, the summary (or only the highlight title,
-- where the rest is shown under Highlights), its pull request, then the
-- body collapsed below. The chips mark where each entry starts, so an
-- entry with chips needs no list marker. An entry without any keeps a bullet,
-- so it doesn't read as a stray paragraph.
local function renderEntryText(entry: UnreleasedChange, context: notesTypes.NotesContext, isTitleOnly: boolean): string
	local isTitle = isTitleOnly and entry.highlight ~= nil
	local text = if isTitle and entry.highlight then entry.highlight else entry.summary

	local chips = renderChips(entry, context.chips)
	if chips ~= "" then
		text = `{chips} {text}`
	end
	if entry.pr then
		text ..= ` ({renderPullRequestLink(entry.pr, context.repositoryUrl)})`
	end
	if entry.body and not isTitle then
		text ..= `\n\n{renderCollapsedBody(entry.body)}`
	end
	return if chips == "" then renderBullet(text) else text
end

return renderEntryText
