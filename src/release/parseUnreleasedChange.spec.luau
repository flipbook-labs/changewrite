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
end)
