local test = require("@std/test")

local promoteHeadings = require("@root/release/promoteHeadings")

test.suite("promoteHeadings", function(suite)
	suite:case("moves each heading up by the given number of levels", function(assert)
		local text = "### Highlights\n\n#### A title\n\n- An entry"

		assert.eq(promoteHeadings(text, 2), "# Highlights\n\n## A title\n\n- An entry")
	end)

	suite:case("moves headings inside a blockquote", function(assert)
		assert.eq(promoteHeadings("> #### A title\n>\n> Body.", 2), "> ## A title\n>\n> Body.")
	end)

	suite:case("stops at level 1", function(assert)
		assert.eq(promoteHeadings("## Close to the top", 2), "# Close to the top")
	end)

	suite:case("leaves fenced code and non-headings alone", function(assert)
		local text = "```sh\n### a shell comment\n```\n\n> ```\n> #### quoted code\n> ```\n\n#hashtag"

		assert.eq(promoteHeadings(text, 2), text)
	end)
end)
