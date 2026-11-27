local constants = require("@root/release/constants")
local excerptItems = require("@root/release/excerptItems")
local isBreaking = require("@root/release/notes/isBreaking")
local isFocused = require("@root/release/notes/isFocused")
local notesTypes = require("@root/release/notes/types")
local renderChips = require("@root/release/notes/renderChips")
local renderPullRequestLink = require("@root/release/notes/renderPullRequestLink")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderBreakingChanges(entries: { UnreleasedChange }, context: notesTypes.NotesContext): string?
	local items: { string } = {}
	local focused: { boolean } = {}
	for _, entry in entries do
		if not isBreaking(entry) then
			continue
		end

		local text = entry.summary
		if entry.pr then
			text ..= ` ({renderPullRequestLink(entry.pr, context.repositoryUrl)})`
		end
		-- A breaking change is where a reader has to act, so its body is
		-- open here rather than collapsed.
		if entry.body then
			text ..= `\n\n{entry.body}`
		end
		local lead = renderChips(entry, context.chips) .. " "
		if entry.highlight then
			table.insert(items, `{lead}**{entry.highlight}**\n\n{text}`)
		else
			table.insert(items, lead .. text)
		end
		table.insert(focused, isFocused(entry, context))
	end

	if context.focus then
		local excerpt = excerptItems(items, focused, constants.EXCERPT_NEIGHBORS)
		if excerpt == nil then
			return nil
		end
		items = excerpt
	end

	if #items == 0 then
		return nil
	end
	return "### Breaking changes\n\n" .. table.concat(items, "\n\n")
end

return renderBreakingChanges
