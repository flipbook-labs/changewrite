local PreviewCommentStep = require("@root/release/PreviewCommentStep")

type PreviewCommentStep = PreviewCommentStep.PreviewCommentStep

export type PlannedCommentStep = {
	step: PreviewCommentStep,
	-- The comment to update or delete. Nil for a new comment.
	commentId: number?,
}

--[[
	What to do with a pull request's preview comments so it ends up with one
	showing `body`, or none when `body` is nil because the pull request adds no
	entries. `existingIds` are the preview comments already on it, oldest
	first. The oldest is kept and updated so the comment stays where it first
	appeared in the conversation, and any others are deleted.
]]
local function planPreviewComment(existingIds: { number }, body: string?): { PlannedCommentStep }
	local steps: { PlannedCommentStep } = {}
	local firstToDelete = 1
	if body then
		if #existingIds == 0 then
			table.insert(steps, {
				step = PreviewCommentStep.Create,
			})
		else
			table.insert(steps, {
				step = PreviewCommentStep.Update,
				commentId = existingIds[1],
			})
			firstToDelete = 2
		end
	end
	for index = firstToDelete, #existingIds do
		table.insert(steps, {
			step = PreviewCommentStep.Delete,
			commentId = existingIds[index],
		})
	end
	return steps
end

return planPreviewComment
