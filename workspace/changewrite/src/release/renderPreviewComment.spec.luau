local test = require("@std/test")

local renderPreviewComment = require("@root/release/renderPreviewComment")

local LEAD = table.concat({
	"# Changelog Preview",
	"",
	"Below is your change in context of next release's changelog. Use this to inform how you write your changelog entry, so it fits well with the others.",
	"",
	"See [Changewrite](https://github.com/flipbook-labs/changewrite) for more.",
}, "\n")

test.suite("renderPreviewComment", function(suite)
	suite:case("puts the excerpt under a rule after the lead", function(assert)
		local comment = renderPreviewComment({
			section = "## v1.1.0\n\n- Add a thing.",
			version = "1.1.0",
			versionWithout = "1.1.0",
			switchesToRichNotes = false,
		})

		assert.eq(comment, `{LEAD}\n\n---\n\n## v1.1.0\n\n- Add a thing.`)
	end)

	suite:case("says when the pull request changes the next release's version", function(assert)
		local comment = renderPreviewComment({
			section = "## v2.0.0",
			version = "2.0.0",
			versionWithout = "1.0.1",
			switchesToRichNotes = false,
		})

		assert.strContains(comment, "\n\nThis pull request changes the next release from v1.0.1 to v2.0.0.\n\n---")
	end)

	suite:case("names no earlier version when the pull request's entries start the release", function(assert)
		local comment = renderPreviewComment({
			section = "## v1.0.1",
			version = "1.0.1",
			switchesToRichNotes = false,
		})

		assert.eq(comment, `{LEAD}\n\n---\n\n## v1.0.1`)
	end)

	suite:case("says when the pull request's entries switch the release to rich notes", function(assert)
		local comment = renderPreviewComment({
			section = "## v1.0.1",
			version = "1.0.1",
			versionWithout = "1.0.1",
			switchesToRichNotes = true,
		})

		assert.strContains(
			comment,
			"\n\nThis pull request's entries switch the release from plain notes to rich notes.\n\n---"
		)
	end)
end)
