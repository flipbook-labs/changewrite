local test = require("@std/test")

local validateConfigFields = require("@root/release/validateConfigFields")

test.suite("validateConfigFields", function(suite)
	suite:case("rejects unknown top-level fields", function(assert)
		local text = [[
unknown = "value"

[version]
current = "1.2.3"
]]

		assert.throws(function()
			validateConfigFields(text)
		end)
	end)

	suite:case("accepts the release branch", function(assert)
		local text = [[
[release]
branch = "release-next"

[version]
current = "1.2.3"
]]

		assert.never.throws(function()
			validateConfigFields(text)
		end)
	end)

	suite:case("rejects unknown release fields", function(assert)
		local text = [[
[release]
branch = "release-next"
unknown = "value"
]]

		assert.throws(function()
			validateConfigFields(text)
		end)
	end)

	suite:case("rejects unknown version fields", function(assert)
		local text = [[
[version]
current = "1.2.3"
unknown = "value"
]]

		assert.throws(function()
			validateConfigFields(text)
		end)
	end)

	suite:case("rejects unknown mirror fields", function(assert)
		local text = [[
[version]
current = "1.2.3"
mirror = [
  { file = "wally.toml", unknown = "value" },
]
]]

		assert.throws(function()
			validateConfigFields(text)
		end)
	end)

	suite:case("rejects unknown single-mirror fields", function(assert)
		local text = [[
[version]
current = "1.2.3"
mirror = { file = "wally.toml", unknown = "value" }
]]

		assert.throws(function()
			validateConfigFields(text)
		end)
	end)
end)
