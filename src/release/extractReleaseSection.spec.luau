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
end)
