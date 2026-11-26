local json = require("@std/json")
local test = require("@std/test")

local getPullRequestHeadSha = require("@root/release/getPullRequestHeadSha")

local function parseEvent(text: string): json.Object?
	return json.asObject(json.deserialize(text))
end

test.suite("getPullRequestHeadSha", function(suite)
	suite:case("reads the head commit of a pull request event", function(assert)
		local event = parseEvent('{"pull_request": {"head": {"sha": "abc123"}}}')

		assert.eq(getPullRequestHeadSha(event), "abc123")
	end)

	suite:case("returns nil outside a pull request", function(assert)
		assert.eq(getPullRequestHeadSha(nil), nil)
		assert.eq(getPullRequestHeadSha(parseEvent('{"ref": "refs/heads/main"}')), nil)
	end)

	suite:case("returns nil when the head has no commit", function(assert)
		assert.eq(getPullRequestHeadSha(parseEvent('{"pull_request": {"head": {}}}')), nil)
		assert.eq(getPullRequestHeadSha(parseEvent('{"pull_request": {"head": {"sha": ""}}}')), nil)
	end)
end)
