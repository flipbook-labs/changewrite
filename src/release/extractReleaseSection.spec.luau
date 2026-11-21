local test = require("@std/test")

local extractReleaseSection = require("@root/release/extractReleaseSection")

local CHANGELOG = table.concat({
	"# Changelog",
	"",
	"All notable changes to this project will be documented in this file.",
	"",
	"## v0.4.0",
	"",
	"### Features",
	"",
	"- Add change partials.",
	"",
	"## v0.3.0",
	"",
	"### Changes",
	"",
	"- Something older.",
}, "\n")

test.suite("extractReleaseSection", function(suite)
	suite:case("returns the newest section without its heading", function(assert)
		assert.eq(extractReleaseSection(CHANGELOG, "0.4.0"), "### Features\n\n- Add change partials.")
	end)

	suite:case("returns an older section bounded by the next heading", function(assert)
		assert.eq(extractReleaseSection(CHANGELOG, "0.3.0"), "### Changes\n\n- Something older.")
	end)

	suite:case("tolerates a leading v in the requested version", function(assert)
		assert.eq(extractReleaseSection(CHANGELOG, "v0.4.0"), "### Features\n\n- Add change partials.")
	end)

	suite:case("errors when the version is absent", function(assert)
		assert.throws(function()
			extractReleaseSection(CHANGELOG, "9.9.9")
		end)
	end)
	suite:case("keeps a non-release level 2 line inside the section", function(assert)
		local changelog = table.concat({
			"## v1.0.0",
			"",
			"```sh",
			"## install twice",
			"```",
			"",
			"## v0.9.0",
			"",
			"- Older.",
		}, "\n")

		assert.eq(extractReleaseSection(changelog, "1.0.0"), "```sh\n## install twice\n```")
	end)

	suite:case("keeps a release heading inside fenced code as part of the section", function(assert)
		local changelog = table.concat({
			"## v1.0.0",
			"",
			"Write the heading like this:",
			"",
			"```markdown",
			"## v0.9.0",
			"```",
			"",
			"~~~",
			"## v0.8.0",
			"~~~",
			"",
			"> ```",
			"> ## v0.7.0",
			"> ```",
			"",
			"- Last line.",
			"",
			"## v0.9.0",
			"",
			"- Older.",
		}, "\n")

		local section = extractReleaseSection(changelog, "1.0.0")
		assert.strContains(section, "```markdown\n## v0.9.0\n```")
		assert.strContains(section, "~~~\n## v0.8.0\n~~~")
		assert.strContains(section, "> ## v0.7.0")
		assert.strContains(section, "- Last line.")
		assert.strNotContains(section, "- Older.")
	end)
end)
