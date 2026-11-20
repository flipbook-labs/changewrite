local test = require("@std/test")

local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")

local function getError(source: string, categories: { string }?, kinds: { string }?): string
	local success, err = pcall(parseUnreleasedChange, source, categories, kinds)
	assert(not success, "expected parseUnreleasedChange to error")
	return tostring(err)
end

test.suite("parseUnreleasedChange", function(suite)
	suite:case("parses the bump, category, and summary", function(assert)
		local source = [[
return {
	bump = "minor",
	category = "Features",
	summary = "Add support for unreleased changes.",
}
]]
		local change = parseUnreleasedChange(source, { "Features", "Fixes" })

		assert.eq(change.bump, "minor")
		assert.eq(change.category, "Features")
		assert.eq(change.summary, "Add support for unreleased changes.")
	end)

	suite:case("reads a table returned through an annotated local", function(assert)
		local source = [[
local types = require("./types")

local entry: types.Entry = {
	bump = "patch",
	summary = "Fix a thing.",
}

return entry
]]
		local change = parseUnreleasedChange(source)

		assert.eq(change.bump, "patch")
		assert.eq(change.summary, "Fix a thing.")
	end)

	suite:case("decodes escapes in quoted strings", function(assert)
		local change = parseUnreleasedChange('return {\n\tbump = "patch",\n\tsummary = "Quote \\"this\\".",\n}\n')

		assert.eq(change.summary, 'Quote "this".')
	end)

	suite:case("reads the description without the block string's surrounding newlines", function(assert)
		local source = [==[
return {
	bump = "patch",
	summary = "Fix a thing.",
	description = [[
It needs a newer Lute.

See the README.
]],
}
]==]
		local change = parseUnreleasedChange(source)

		assert.eq(change.summary, "Fix a thing.")
		assert.eq(change.description, "It needs a newer Lute.\n\nSee the README.")
	end)

	suite:case("defaults the category to Changes when no categories are configured", function(assert)
		local change = parseUnreleasedChange('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n')

		assert.eq(change.category, "Changes")
	end)

	suite:case("errors on a category outside the configured list, naming its line", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tcategory = "Misc",\n\tsummary = "Fix a thing.",\n}\n'
		local err = getError(source, { "Features", "Fixes" })

		assert.strContains(err, 'line 3: Unreleased change category "Misc" is not configured')
		assert.strContains(err, "Features, Fixes")
	end)

	suite:case("requires a category once categories are configured", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n', { "Fixes" })

		assert.strContains(err, "has no category")
	end)

	suite:case("errors on an invalid bump", function(assert)
		local err = getError('return {\n\tbump = "huge",\n\tsummary = "Fix a thing.",\n}\n')

		assert.strContains(err, 'Unknown version component "huge"')
	end)

	suite:case("requires a summary", function(assert)
		local err = getError('return {\n\tbump = "patch",\n}\n')

		assert.strContains(err, "has no summary")
	end)

	suite:case("rejects a field it doesn't know, naming its line", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n\ttype = "fix",\n}\n')

		assert.strContains(err, 'line 4: Unreleased change has an unknown field "type"')
	end)

	suite:case("rejects a field set twice", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tbump = "minor",\n\tsummary = "Fix a thing.",\n}\n')

		assert.strContains(err, "line 3: Unreleased change sets bump more than once")
	end)

	suite:case("rejects a value that isn't a literal", function(assert)
		local err = getError('local bump = "patch"\n\nreturn {\n\tbump = bump,\n\tsummary = "Fix a thing.",\n}\n')

		assert.strContains(err, "line 4: Unreleased change bump must be a string")
	end)

	suite:case("rejects a file that doesn't return a table", function(assert)
		assert.strContains(getError("return nil\n"), "must return a table")
	end)

	suite:case("rejects a file that isn't valid Luau", function(assert)
		assert.strContains(getError("---\nbump: patch\n---\n\nFix a thing.\n"), "not valid Luau")
	end)

	suite:case("leaves the release-notes fields empty when they are not set", function(assert)
		local change = parseUnreleasedChange('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n')

		assert.eq(change.description, nil)
		assert.eq(change.kind, nil)
		assert.eq(#change.flags, 0)
		assert.eq(change.highlight, nil)
		assert.eq(change.pr, nil)
	end)

	suite:case("parses kind, flags, highlight, and pr", function(assert)
		local source = [[
return {
	bump = "major",
	kind = "engine",
	flags = { "breaking", "security", "breaking" },
	highlight = "Embedded runtime",
	pr = 42,
	summary = "Add an embedded runtime.",
}
]]
		local change = parseUnreleasedChange(source, nil, { "engine" })

		assert.eq(change.kind, "engine")
		assert.eq(#change.flags, 2)
		assert.eq(change.flags[1], "breaking")
		assert.eq(change.flags[2], "security")
		assert.eq(change.highlight, "Embedded runtime")
		assert.eq(change.pr, 42)
	end)

	suite:case("requires a kind once kinds are configured", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n', nil, { "docs", "engine" })

		assert.strContains(err, "has no kind. Expected one of: docs, engine")
	end)

	suite:case("rejects a kind changewrite.toml doesn't configure", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tkind = "added",\n\tsummary = "Fix a thing.",\n}\n'
		local err = getError(source, nil, { "engine" })

		assert.strContains(err, 'line 3: Unreleased change kind "added" is not configured. Expected one of: engine')
	end)

	suite:case("points at changewrite.toml when no kinds are configured", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tkind = "engine",\n\tsummary = "Fix a thing.",\n}\n'

		assert.strContains(getError(source), "Add a [kind.engine] table to changewrite.toml")
	end)

	suite:case("rejects an unknown flag", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tflags = { "experimental" },\n\tsummary = "Fix a thing.",\n}\n'

		assert.strContains(getError(source), 'flag "experimental" is not supported')
	end)

	suite:case("rejects flags written as a string", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tflags = "breaking",\n\tsummary = "Fix a thing.",\n}\n'

		assert.strContains(getError(source), "flags must be a list")
	end)

	suite:case("rejects a pr that isn't a whole number", function(assert)
		local quoted = 'return {\n\tbump = "patch",\n\tpr = "#42",\n\tsummary = "Fix a thing.",\n}\n'
		local fractional = 'return {\n\tbump = "patch",\n\tpr = 4.2,\n\tsummary = "Fix a thing.",\n}\n'

		assert.strContains(getError(quoted), "pr must be a pull request number")
		assert.strContains(getError(fractional), "pr must be a pull request number")
	end)
end)
