local ChangeKind = require("@root/release/ChangeKind")
local renderChips = require("@root/release/notes/renderChips")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderHighlights(entries: { UnreleasedChange }, repositoryUrl: string?): string?
	local blocks: { string } = {}
	for _, entry in entries do
		local title = entry.highlight
		if title == nil then
			continue
		end

		local chips = renderChips(entry)
		local heading = if chips == "" then `#### {title}` else `#### {chips} {title}`
		if entry.kind == ChangeKind.Breaking then
			-- The full entry is already under Breaking changes, which is where a
			-- reader has to act, so the highlight only points there.
			table.insert(blocks, `{heading}\n\nSee [Breaking changes](#breaking-changes).`)
			continue
		end

		local body = entry.body
		if entry.pr then
			body ..= ` ({renderPullRequestLink(entry.pr, repositoryUrl)})`
		end
		table.insert(blocks, `{heading}\n\n{body}`)
	end

	if #blocks == 0 then
		return nil
	end
	return "### Highlights\n\n" .. table.concat(blocks, "\n\n")
end

return renderHighlights
