local isBreaking = require("@root/release/notes/isBreaking")
local notesTypes = require("@root/release/notes/types")
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

local function renderHighlights(entries: { UnreleasedChange }, context: notesTypes.NotesContext): string?
	local blocks: { string } = {}
	for _, entry in entries do
		local title = entry.highlight
		if title == nil then
			continue
		end

		local chips = renderChips(entry, context.chips)
		-- A bold line rather than a heading, because GitHub renders heading text
		-- larger than the chips and the two stop lining up.
		local heading = if chips == "" then `**{title}**` else `{chips} **{title}**`
		if isBreaking(entry) then
			-- The full entry is already under Breaking changes, which is where a
			-- reader has to act, so the highlight only points there.
			table.insert(blocks, quote(`{heading}\n\nSee [Breaking changes](#breaking-changes).`))
			continue
		end

		local text = entry.summary
		if entry.pr then
			text ..= ` ({renderPullRequestLink(entry.pr, context.repositoryUrl)})`
		end
		-- A highlight is a change readers shouldn't miss, so its body is
		-- open here rather than collapsed.
		if entry.body then
			text ..= `\n\n{entry.body}`
		end
		table.insert(blocks, quote(`{heading}\n\n{text}`))
	end

	if #blocks == 0 then
		return nil
	end
	return "### Highlights\n\n" .. table.concat(blocks, "\n\n")
end

return renderHighlights
