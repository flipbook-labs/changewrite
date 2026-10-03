local json = require("@std/json")
local test = require("@std/test")

local isSameRepositoryPullRequest = require("@root/release/isSameRepositoryPullRequest")

local function parseEvent(text: string): json.Object?
	return json.asObject(json.deserialize(text))
end

local function pullRequest(head: string, base: string): json.Object?
	return parseEvent(`\{"pull_request": \{"head": \{"repo": {head}}, "base": \{"repo": \{"full_name": "{base}"}}}}`)
end

test.suite("isSameRepositoryPullRequest", function(suite)
	suite:case("matches a pull request from a branch in the same repository", function(assert)
		local event = pullRequest(`\{"full_name": "flipbook-labs/changewrite"}`, "flipbook-labs/changewrite")
		assert.eq(isSameRepositoryPullRequest(event), true)
	end)

	suite:case("rejects a pull request from a fork", function(assert)
		local event = pullRequest(`\{"full_name": "someone/changewrite"}`, "flipbook-labs/changewrite")
		assert.eq(isSameRepositoryPullRequest(event), false)
	end)

	suite:case("rejects a pull request whose fork was deleted", function(assert)
		local event = pullRequest("null", "flipbook-labs/changewrite")
		assert.eq(isSameRepositoryPullRequest(event), false)
	end)

	suite:case("rejects an event without a pull request", function(assert)
		assert.eq(isSameRepositoryPullRequest(parseEvent(`\{"ref": "refs/heads/main"}`)), false)
	end)

	suite:case("rejects a missing event", function(assert)
		assert.eq(isSameRepositoryPullRequest(nil), false)
	end)
end)
