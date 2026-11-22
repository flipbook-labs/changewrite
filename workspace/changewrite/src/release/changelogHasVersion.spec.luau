local test = require("@std/test")

local changelogHasVersion = require("@root/release/changelogHasVersion")

local CHANGELOG = table.concat({
	"# Changelog",
	"",
	"All notable changes to this project will be documented in this file.",
	"",
	"## v0.2.0",
	"",
	"### Features",
	"",
	"- Something new.",
	"",
	"## v0.1.0",
	"",
	"### Changes",
	"",
	"- The first release.",
}, "\n")

test.suite("changelogHasVersion", function(suite)
	suite:case("finds a version that has a section", function(assert)
		assert.eq(changelogHasVersion(CHANGELOG, "0.2.0"), true)
		assert.eq(changelogHasVersion(CHANGELOG, "0.1.0"), true)
	end)

	suite:case("ignores a leading v on the queried version", function(assert)
		assert.eq(changelogHasVersion(CHANGELOG, "v0.2.0"), true)
	end)

	suite:case("returns false when there is no matching section", function(assert)
		assert.eq(changelogHasVersion(CHANGELOG, "0.3.0"), false)
	end)

	suite:case("does not match a version that is only a prefix", function(assert)
		assert.eq(changelogHasVersion("## v0.1.0", "0.1"), false)
	end)

	suite:case("matches a heading with a trailing suffix", function(assert)
		assert.eq(changelogHasVersion("## v0.1.0 - 2026-01-01", "0.1.0"), true)
	end)

	suite:case("returns false for an empty changelog", function(assert)
		assert.eq(changelogHasVersion("", "0.1.0"), false)
	end)

	suite:case("matches a heading at any depth", function(assert)
		assert.eq(changelogHasVersion("# v0.1.0", "0.1.0"), true)
		assert.eq(changelogHasVersion("### v0.1.0", "0.1.0"), true)
	end)
end)
