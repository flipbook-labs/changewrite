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
		assert.eq(change.body, nil)
	end)

	suite:case("reads a table returned through a local", function(assert)
		local source = [[
local entry = {
	bump = "patch",
	summary = "Fix a thing.",
}

return entry
]]
		local change = parseUnreleasedChange(source)

		assert.eq(change.bump, "patch")
		assert.eq(change.summary, "Fix a thing.")
	end)

	suite:case("reads a value computed from a local", function(assert)
		local source = [[
local bump = "patch"

return {
	bump = bump,
	summary = "Fix " .. "a thing.",
}
]]
		local change = parseUnreleasedChange(source)

		assert.eq(change.bump, "patch")
		assert.eq(change.summary, "Fix a thing.")
	end)

	suite:case("reads the body without the block string's surrounding newlines", function(assert)
		local source = [==[
return {
	bump = "patch",
	summary = "Fix a thing.",
	body = [[
It needs a newer Lute.

See the README.
]],
}
]==]
		local change = parseUnreleasedChange(source)

		assert.eq(change.summary, "Fix a thing.")
		assert.eq(change.body, "It needs a newer Lute.\n\nSee the README.")
	end)

	suite:case("builds a body from paragraphs joined with table.concat", function(assert)
		local source = [[
return {
	bump = "patch",
	summary = "Fix a thing.",
	body = table.concat({
		"It needs a newer Lute.",
		"See the README.",
	}, "\n\n"),
}
]]
		local change = parseUnreleasedChange(source)

		assert.eq(change.body, "It needs a newer Lute.\n\nSee the README.")
	end)

	suite:case("rejects an entry that requires a module", function(assert)
		local source = 'local fs = require("@std/fs")\n\nreturn {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n'
		local err = getError(source)

		assert.strContains(err, "Unreleased change failed to run")
		assert.strContains(err, "attempt to call a nil value")
	end)

	suite:case("rejects an entry that reaches for os", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tsummary = `Fixed at {os.time()}.`,\n}\n'

		assert.strContains(getError(source), "Unreleased change failed to run")
	end)

	suite:case("names the globals an entry can use when it fails to run", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = process.env.HOME,\n}\n')

		assert.strContains(err, "math, select, string, table")
	end)

	suite:case("keeps a global one entry sets from reaching the next", function(assert)
		local first =
			parseUnreleasedChange('shared = "Fix a thing."\n\nreturn {\n\tbump = "patch",\n\tsummary = shared,\n}\n')
		local err = getError('return {\n\tbump = "patch",\n\tsummary = shared,\n}\n')

		assert.eq(first.summary, "Fix a thing.")
		assert.strContains(err, "has no summary")
	end)

	suite:case("keeps an entry from changing a library for the entries after it", function(assert)
		local err = getError(
			'string.upper = function()\n\treturn "changed"\nend\n\nreturn {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n'
		)
		local next =
			parseUnreleasedChange('return {\n\tbump = "patch",\n\tsummary = string.upper("fix a thing."),\n}\n')

		assert.strContains(err, "Unreleased change failed to run")
		assert.eq(next.summary, "FIX A THING.")
	end)

	suite:case("defaults the category to Changes when no categories are configured", function(assert)
		local change = parseUnreleasedChange('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n')

		assert.eq(change.category, "Changes")
	end)

	suite:case("errors on a category outside the configured list", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tcategory = "Misc",\n\tsummary = "Fix a thing.",\n}\n'
		local err = getError(source, { "Features", "Fixes" })

		assert.strContains(err, 'Unreleased change category "Misc" is not configured')
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

	suite:case("rejects a field it doesn't know", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n\ttype = "fix",\n}\n')

		assert.strContains(err, 'Unreleased change has an unknown field "type"')
	end)

	suite:case("rejects a value written without a field name", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n\t"Extra text.",\n}\n')

		assert.strContains(err, "fields must be written as `name = value`")
	end)

	suite:case("rejects a field set twice", function(assert)
		local source =
			'return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n\tsummary = "Fix another thing.",\n}\n'
		local err = getError(source)

		assert.strContains(err, 'Unreleased change sets "summary" more than once (line 4)')
	end)

	suite:case("rejects a field set twice when one uses a bracketed key", function(assert)
		local source = 'return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n\t["bump"] = "minor",\n}\n'

		assert.strContains(getError(source), 'sets "bump" more than once')
	end)

	suite:case("rejects a key repeated in a table the entry builds", function(assert)
		local source =
			'local parts = { first = "Fix", first = "Add" }\n\nreturn {\n\tbump = "patch",\n\tsummary = parts.first,\n}\n'

		assert.strContains(getError(source), 'sets "first" more than once (line 1)')
	end)

	suite:case("rejects a string field set to another type", function(assert)
		local err = getError('return {\n\tbump = "patch",\n\tsummary = 42,\n}\n')

		assert.strContains(err, "Unreleased change summary must be a string")
	end)

	suite:case("rejects a file that doesn't return a table", function(assert)
		assert.strContains(getError("return nil\n"), "must return a table")
	end)

	suite:case("rejects a file that isn't valid Luau", function(assert)
		assert.strContains(getError("---\nbump: patch\n---\n\nFix a thing.\n"), "not valid Luau")
	end)

	suite:case("leaves the release-notes fields empty when they are not set", function(assert)
		local change = parseUnreleasedChange('return {\n\tbump = "patch",\n\tsummary = "Fix a thing.",\n}\n')

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

		assert.strContains(err, 'Unreleased change kind "added" is not configured. Expected one of: engine')
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
