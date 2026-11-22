local test = require("@std/test")

local convertMarkdownEntry = require("@root/entries/convertMarkdownEntry")
local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")

test.suite("convertMarkdownEntry", function(suite)
	suite:case("writes an entry with the frontmatter fields and summary", function(assert)
		local source = convertMarkdownEntry("---\nbump: patch\ncategory: Fixes\nkind: cli\n---\n\nFix a thing.\n")

		assert.eq(
			source,
			table.concat({
				"return {",
				'\tbump = "patch",',
				'\tcategory = "Fixes",',
				'\tkind = "cli",',
				'\tsummary = "Fix a thing.",',
				"}",
				"",
			}, "\n")
		)
	end)

	suite:case("joins a wrapped first paragraph into a one-line summary", function(assert)
		local source = convertMarkdownEntry("---\nbump: patch\n---\n\nFix a thing\nthat wrapped.\n")

		assert.strContains(source, '\tsummary = "Fix a thing that wrapped.",\n')
	end)

	suite:case("moves the paragraphs after the first into a block-string body", function(assert)
		local source = convertMarkdownEntry("---\nbump: patch\n---\n\nFix a thing.\n\nMore detail.\n\nEven more.\n")

		assert.strContains(source, "\tbody = [[\nMore detail.\n\nEven more.\n]],\n")
	end)

	suite:case("raises the block-string level when the body contains ]]", function(assert)
		local source = convertMarkdownEntry("---\nbump: patch\n---\n\nFix a thing.\n\nIndex t[a[1]] here.\n")

		assert.strContains(source, "[=[\nIndex t[a[1]] here.\n]=]")
	end)

	suite:case("escapes quotes and backslashes in the summary", function(assert)
		local source = convertMarkdownEntry('---\nbump: patch\n---\n\nQuote "this" and a \\ backslash.\n')

		assert.strContains(source, '\tsummary = "Quote \\"this\\" and a \\\\ backslash.",\n')
	end)

	suite:case("converts flags and pr", function(assert)
		local source =
			convertMarkdownEntry("---\nbump: major\nflags: [breaking, 'security']\npr: #42\n---\n\nDrop it.\n")

		assert.strContains(source, '\tflags = { "Breaking", "Security" },\n')
		assert.strContains(source, "\tpr = 42,\n")
	end)

	suite:case("produces an entry that reads back to the same body and fields", function(assert)
		local markdown = [[
---
bump: minor
category: Features
kind: cli
flags: breaking
highlight: Luau entries
pr: 97
---

Read changelog entries written in Luau.

Run `changewrite check --fix` to convert "Markdown" entries.
]]
		local change = parseUnreleasedChange(convertMarkdownEntry(markdown), { "Features" }, { "cli" })

		assert.eq(change.bump, "minor")
		assert.eq(change.category, "Features")
		assert.eq(change.kind, "cli")
		assert.eq(change.flags[1], "Breaking")
		assert.eq(change.highlight, "Luau entries")
		assert.eq(change.pr, 97)
		assert.eq(change.summary, "Read changelog entries written in Luau.")
		assert.eq(change.body, 'Run `changewrite check --fix` to convert "Markdown" entries.')
	end)

	suite:case("rejects a frontmatter field Changewrite doesn't read", function(assert)
		local success, err = pcall(convertMarkdownEntry, "---\nbump: patch\ntype: fix\n---\n\nFix a thing.\n")

		assert.eq(success, false)
		assert.strContains(tostring(err), 'unknown field "type"')
	end)
end)
