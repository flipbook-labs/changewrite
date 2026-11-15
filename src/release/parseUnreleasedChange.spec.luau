local test = require("@std/test")

local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")

test.suite("parseUnreleasedChange", function(suite)
	suite:case("parses the bump, category, and body", function(assert)
		local text = [[
---
bump: minor
category: Features
---

Add support for unreleased changes.
]]
		local change = parseUnreleasedChange(text, { "Features", "Fixes", "Changes", "Dependencies" })

		assert.eq(change.bump, "minor")
		assert.eq(change.category, "Features")
		assert.eq(change.body, "Add support for unreleased changes.")
	end)

	suite:case("defaults the category to Changes", function(assert)
		local text = [[
---
bump: patch
---

Fix a thing.
]]
		local change = parseUnreleasedChange(text, { "Features", "Fixes", "Changes", "Dependencies" })

		assert.eq(change.category, "Changes")
	end)

	suite:case("tolerates quoted frontmatter values", function(assert)
		local text = [[
---
bump: "major"
category: 'Breaking'
---

Drop the old API.
]]
		local change = parseUnreleasedChange(text, { "Breaking" })

		assert.eq(change.bump, "major")
		assert.eq(change.category, "Breaking")
	end)

	suite:case("accepts a configured category", function(assert)
		local text = [[
---
bump: minor
category: Features
---

Add category validation.
]]
		local change = parseUnreleasedChange(text, { "Features", "Fixes" })

		assert.eq(change.category, "Features")
	end)

	suite:case("errors on a category outside the configured list", function(assert)
		local text = [[
---
bump: patch
category: Internal
---

Use an invalid category.
]]

		assert.throws(function()
			parseUnreleasedChange(text, { "Features", "Fixes" })
		end)
	end)

	suite:case("allows unrestricted categories when none are configured", function(assert)
		local text = [[
---
bump: patch
category: Internal
---

Use a category without configuring it.
]]
		local change = parseUnreleasedChange(text)

		assert.eq(change.category, "Internal")
	end)

	suite:case("validates the default category against the configured list", function(assert)
		local text = [[
---
bump: patch
---

Use the default category.
]]

		assert.throws(function()
			parseUnreleasedChange(text, { "Features", "Fixes" })
		end)
	end)

	suite:case("preserves multi-paragraph bodies", function(assert)
		local text = [[
---
bump: minor
---

First paragraph.

Second paragraph.
]]
		local change = parseUnreleasedChange(text, { "Changes" })

		assert.eq(change.body, "First paragraph.\n\nSecond paragraph.")
	end)

	suite:case("errors on an invalid bump", function(assert)
		local text = [[
---
bump: huge
---

Nope.
]]

		assert.throws(function()
			parseUnreleasedChange(text)
		end)
	end)

	suite:case("errors when frontmatter is missing", function(assert)
		local text = "Just a body, no frontmatter.\n"

		assert.throws(function()
			parseUnreleasedChange(text)
		end)
	end)
	suite:case("leaves the release-notes fields empty when they are not set", function(assert)
		local change = parseUnreleasedChange("---\nbump: patch\n---\n\nFix a thing.\n")

		assert.eq(change.kind, nil)
		assert.eq(#change.flags, 0)
		assert.eq(change.highlight, nil)
		assert.eq(change.pr, nil)
	end)

	suite:case("parses kind, flags, highlight, and pr", function(assert)
		local text = [[
---
bump: minor
kind: engine
flags: breaking, security
highlight: "Flipbook in your experience"
pr: "#652"
---

Add an embedded runtime.
]]
		local change = parseUnreleasedChange(text, nil, { "docs", "engine" })

		assert.eq(change.kind, "engine")
		assert.eq(#change.flags, 2)
		assert.eq(change.flags[1], "breaking")
		assert.eq(change.flags[2], "security")
		assert.eq(change.highlight, "Flipbook in your experience")
		assert.eq(change.pr, 652)
	end)

	suite:case("accepts flags written as a bracketed list and drops repeats", function(assert)
		local change =
			parseUnreleasedChange("---\nbump: patch\nflags: [deprecated, 'security', deprecated]\n---\n\nBody.\n")

		assert.eq(#change.flags, 2)
		assert.eq(change.flags[1], "deprecated")
		assert.eq(change.flags[2], "security")
	end)

	suite:case("rejects a kind changewrite.toml doesn't configure", function(assert)
		local success, err =
			pcall(parseUnreleasedChange, "---\nbump: patch\nkind: added\n---\n\nBody.\n", nil, { "engine" })

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), 'kind "added" is not configured. Expected one of: engine', 1, true), nil)
	end)

	suite:case("points at changewrite.toml when no kinds are configured", function(assert)
		local success, err = pcall(parseUnreleasedChange, "---\nbump: patch\nkind: engine\n---\n\nBody.\n", nil, nil)

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), "Add a [kind.engine] table", 1, true), nil)
	end)

	suite:case("rejects an unknown flag", function(assert)
		local success, err =
			pcall(parseUnreleasedChange, "---\nbump: patch\nflags: breaking, experimental\n---\n\nBody.\n", nil, nil)

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), 'flag "experimental" is not supported', 1, true), nil)
	end)

	suite:case("rejects a pr that is not a number", function(assert)
		local success, err = pcall(parseUnreleasedChange, "---\nbump: patch\npr: abc\n---\n\nBody.\n", nil, nil)

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), "must be a pull request number", 1, true), nil)
	end)
end)
