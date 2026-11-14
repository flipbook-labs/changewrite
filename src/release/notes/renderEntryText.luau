local renderChips = require("@root/release/notes/renderChips")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- The text of one list item: chips, then the entry's body (or only its
-- highlight title, where the full body is shown elsewhere in the notes), then
-- its pull request.
local function renderEntryText(entry: UnreleasedChange, repositoryUrl: string?, isTitleOnly: boolean): string
	local text = if isTitleOnly and entry.highlight then entry.highlight else entry.body

	local chips = renderChips(entry)
	if chips ~= "" then
		text = `{chips} {text}`
	end
	if entry.pr then
		text ..= ` ({renderPullRequestLink(entry.pr, repositoryUrl)})`
	end
	return text
end

return renderEntryText
