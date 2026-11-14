local ChangeKind = require("@root/release/ChangeKind")
local renderChips = require("@root/release/notes/renderChips")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- Wraps a highlight in a blockquote, so its heading and body read as one unit
-- with a rule down the side. GitHub strips the CSS a bordered box would need.
local function quote(text: string): string
	local lines: { string } = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, if line == "" then ">" else `> {line}`)
	end
	return table.concat(lines, "\n")
end

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
			table.insert(blocks, quote(`{heading}\n\nSee [Breaking changes](#breaking-changes).`))
			continue
		end

		local body = entry.body
		if entry.pr then
			body ..= ` ({renderPullRequestLink(entry.pr, repositoryUrl)})`
		end
		table.insert(blocks, quote(`{heading}\n\n{body}`))
	end

	if #blocks == 0 then
		return nil
	end
	return "### Highlights\n\n" .. table.concat(blocks, "\n\n")
end

return renderHighlights
