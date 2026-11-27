export type PreviewCommentStep = "create" | "update" | "delete"

local PreviewCommentStep = table.freeze({
	Create = "create" :: PreviewCommentStep,
	Update = "update" :: PreviewCommentStep,
	Delete = "delete" :: PreviewCommentStep,
})

return PreviewCommentStep
