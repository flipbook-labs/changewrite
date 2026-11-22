local test = require("@std/test")

local assertConfigVersionLiteral = require("@root/release/assertConfigVersionLiteral")

local function getError(content: string, current: string?): string
	local success, err = pcall(assertConfigVersionLiteral, content, current)
	assert(not success, "expected assertConfigVersionLiteral to error")
	return tostring(err)
end

test.suite("assertConfigVersionLiteral", function(suite)
	suite:case("accepts a config whose only `current` is the version", function(assert)
		assert.never.throws(function()
			assertConfigVersionLiteral('return {\n\tversion = { current = "1.2.3" },\n}\n', "1.2.3")
		end)
	end)

	suite:case("rejects a config that assigns `current` twice", function(assert)
		local content = 'local current = "0.0.1"\n\nreturn {\n\tversion = { current = "1.2.3" },\n}\n'

		assert.strContains(getError(content, "1.2.3"), "assigns `current` more than once")
	end)

	suite:case("rejects a version that isn't written as a string", function(assert)
		local content = "local major = 1\n\nreturn {\n\tversion = { current = `{major}.0.0` },\n}\n"

		assert.strContains(getError(content, "1.0.0"), "Write `version.current` as a string")
	end)

	suite:case("rejects a `current` that holds some other value", function(assert)
		local content = table.concat({
			'local legacy = { current = "0.9.0" }',
			"",
			"return {",
			'\tversion = { current = string.format("%d.0.0", 1) },',
			"}",
			"",
		}, "\n")

		assert.strContains(getError(content, "1.0.0"), 'holds "0.9.0", which doesn\'t match `version.current`')
	end)
end)
