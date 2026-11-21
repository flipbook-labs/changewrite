local isBreaking = require("@root/release/notes/isBreaking")
local notesTypes = require("@root/release/notes/types")
local renderChips = require("@root/release/notes/renderChips")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderBreakingChanges(entries: { UnreleasedChange }, context: notesTypes.NotesContext): string?
	local items: { string } = {}
	for _, entry in entries do
		if not isBreaking(entry) then
			continue
		end

		local body = entry.summary
		if entry.pr then
			body ..= ` ({renderPullRequestLink(entry.pr, context.repositoryUrl)})`
		end
		-- A breaking change is where a reader has to act, so its description is
		-- open here rather than collapsed.
		if entry.description then
			body ..= `\n\n{entry.description}`
		end
		local lead = renderChips(entry, context.chips) .. " "
		if entry.highlight then
			table.insert(items, `{lead}**{entry.highlight}**\n\n{body}`)
		else
			table.insert(items, lead .. body)
		end
	end

	if #items == 0 then
		return nil
	end
	return "### Breaking changes\n\n" .. table.concat(items, "\n\n")
end

return renderBreakingChanges
