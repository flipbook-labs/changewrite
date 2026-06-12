local test = require("@std/test")

local cli = require("@batteries/cli")
local helpText = require("@root/cli/helpText")

local function makeParser()
	local parser = cli.parser()
	parser:add("name", "option", {
		help = "Place name",
		default = "main",
	})
	parser:add("pr", "option", {
		help = "PR number",
		required = true,
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})
	return parser
end

test.suite("helpText.build", function(suite)
	local output: string

	suite:beforeAll(function()
		output = helpText.build(makeParser(), {
			title = "test-cli example",
			summary = "A test command.",
		})
	end)

	suite:case("includes the title", function(assert)
		assert.strContains(output, "test-cli example")
	end)

	suite:case("includes the summary", function(assert)
		assert.strContains(output, "A test command.")
	end)

	suite:case("includes USAGE section", function(assert)
		assert.strContains(output, "USAGE:")
	end)

	suite:case("includes REQUIRED section with required args", function(assert)
		assert.strContains(output, "REQUIRED:")
		assert.strContains(output, "--pr <pr>")
	end)

	suite:case("includes OPTIONS section with optional args and defaults", function(assert)
		assert.strContains(output, "OPTIONS:")
		assert.strContains(output, "--name <name>")
		assert.strContains(output, "(default: main)")
	end)
end)

test.suite("helpText.buildRoot", function(suite)
	local output: string

	suite:beforeAll(function()
		output = helpText.buildRoot({
			title = "test-cli",
			summary = "Test root help.",
			commands = {
				{ name = "deploy", description = "Deploy a place" },
			},
		})
	end)

	suite:case("includes the title", function(assert)
		assert.strContains(output, "test-cli")
	end)

	suite:case("includes COMMANDS section", function(assert)
		assert.strContains(output, "COMMANDS:")
	end)

	suite:case("includes command names", function(assert)
		assert.strContains(output, "deploy")
	end)
end)
