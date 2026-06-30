local test = require("@std/test")

local parseUnreleasedChange = require("@root/release/parseUnreleasedChange")

test.suite("parseUnreleasedChange", function(suite)
	suite:case("parses the bump, category, and body", function(assert)
		local change = parseUnreleasedChange([[
---
bump: minor
category: Features
---

Add support for unreleased changes.
]])

		assert.eq(change.bump, "minor")
		assert.eq(change.category, "Features")
		assert.eq(change.body, "Add support for unreleased changes.")
	end)

	suite:case("defaults the category to Changes", function(assert)
		local change = parseUnreleasedChange([[
---
bump: patch
---

Fix a thing.
]])

		assert.eq(change.category, "Changes")
	end)

	suite:case("tolerates quoted frontmatter values", function(assert)
		local change = parseUnreleasedChange([[
---
bump: "major"
category: 'Breaking'
---

Drop the old API.
]])

		assert.eq(change.bump, "major")
		assert.eq(change.category, "Breaking")
	end)

	suite:case("preserves multi-paragraph bodies", function(assert)
		local change = parseUnreleasedChange([[
---
bump: minor
---

First paragraph.

Second paragraph.
]])

		assert.eq(change.body, "First paragraph.\n\nSecond paragraph.")
	end)

	suite:case("errors on an invalid bump", function(assert)
		assert.throws(function()
			parseUnreleasedChange([[
---
bump: huge
---

Nope.
]])
		end)
	end)

	suite:case("errors when frontmatter is missing", function(assert)
		assert.throws(function()
			parseUnreleasedChange("Just a body, no frontmatter.\n")
		end)
	end)
end)
