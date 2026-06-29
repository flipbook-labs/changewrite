local test = require("@std/test")

local changePartials = require("@root/release/changePartials")

test.suite("changePartials._parsePartial", function(suite)
	suite:case("parses the bump, category, and body", function(assert)
		local partial = changePartials._parsePartial([[
---
bump: minor
category: Features
---

Add support for change partials.
]])

		assert.eq(partial.bump, "minor")
		assert.eq(partial.category, "Features")
		assert.eq(partial.body, "Add support for change partials.")
	end)

	suite:case("defaults the category to Changes", function(assert)
		local partial = changePartials._parsePartial([[
---
bump: patch
---

Fix a thing.
]])

		assert.eq(partial.category, "Changes")
	end)

	suite:case("tolerates quoted frontmatter values", function(assert)
		local partial = changePartials._parsePartial([[
---
bump: "major"
category: 'Breaking'
---

Drop the old API.
]])

		assert.eq(partial.bump, "major")
		assert.eq(partial.category, "Breaking")
	end)

	suite:case("preserves multi-paragraph bodies", function(assert)
		local partial = changePartials._parsePartial([[
---
bump: minor
---

First paragraph.

Second paragraph.
]])

		assert.eq(partial.body, "First paragraph.\n\nSecond paragraph.")
	end)

	suite:case("errors on an invalid bump", function(assert)
		assert.throws(function()
			changePartials._parsePartial([[
---
bump: huge
---

Nope.
]])
		end)
	end)

	suite:case("errors when frontmatter is missing", function(assert)
		assert.throws(function()
			changePartials._parsePartial("Just a body, no frontmatter.\n")
		end)
	end)
end)
