local test = require("@std/test")

local planPreviewComment = require("@root/release/planPreviewComment")

test.suite("planPreviewComment", function(suite)
	suite:case("creates a comment when the pull request has none", function(assert)
		assert.eq(planPreviewComment({}, "preview"), {
			{
				step = "create",
			},
		})
	end)

	suite:case("updates the oldest comment and deletes the rest", function(assert)
		assert.eq(planPreviewComment({ 11, 12, 13 }, "preview"), {
			{
				step = "update",
				commentId = 11,
			},
			{
				step = "delete",
				commentId = 12,
			},
			{
				step = "delete",
				commentId = 13,
			},
		})
	end)

	suite:case("deletes every comment once the pull request adds no entries", function(assert)
		assert.eq(planPreviewComment({ 11, 12 }, nil), {
			{
				step = "delete",
				commentId = 11,
			},
			{
				step = "delete",
				commentId = 12,
			},
		})
	end)

	suite:case("does nothing when there is no preview and no comment", function(assert)
		assert.eq(planPreviewComment({}, nil), {})
	end)
end)
