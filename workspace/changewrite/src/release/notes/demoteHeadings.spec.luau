local test = require("@std/test")

local demoteHeadings = require("@root/release/notes/demoteHeadings")

test.suite("demoteHeadings", function(suite)
	suite:case("shifts level 1 and 2 headings to level 4", function(assert)
		assert.eq(
			demoteHeadings("Intro.\n\n# Overview\n\n## Migration\n\nSteps."),
			"Intro.\n\n#### Overview\n\n#### Migration\n\nSteps."
		)
	end)

	suite:case("leaves deeper headings and other lines alone", function(assert)
		assert.eq(demoteHeadings("### Details\n#hashtag\nText ## here"), "### Details\n#hashtag\nText ## here")
	end)

	suite:case("leaves lines inside fenced code blocks alone", function(assert)
		assert.eq(
			demoteHeadings("```sh\n# install\n## twice\n```\n## After"),
			"```sh\n# install\n## twice\n```\n#### After"
		)
	end)
	suite:case("keeps a fence open until a closing line at least as long", function(assert)
		assert.eq(demoteHeadings("````md\n```\n# literal\n````\n## After"), "````md\n```\n# literal\n````\n#### After")
	end)

	suite:case("doesn't close a backtick fence with tildes", function(assert)
		assert.eq(demoteHeadings("```\n~~~\n# literal\n```\n# After"), "```\n~~~\n# literal\n```\n#### After")
	end)
end)
