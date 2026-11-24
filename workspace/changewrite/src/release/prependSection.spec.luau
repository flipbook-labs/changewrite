local test = require("@std/test")

local prependSection = require("@root/release/prependSection")

local HEADER = "# Changelog\n\nAll notable changes to this project will be documented in this file."
local SECTION = "## v0.2.0\n\n- Something new."
local EARLIER_RELEASE = "## v0.1.0\n\n- The first release."

local EXPECTED_WITH_EARLIER_RELEASE = HEADER .. "\n\n" .. SECTION .. "\n\n" .. EARLIER_RELEASE .. "\n"

test.suite("prependSection", function(suite)
	suite:case("separates the header from the first section with one blank line", function(assert)
		assert.eq(prependSection(HEADER, SECTION), HEADER .. "\n\n" .. SECTION .. "\n")
	end)

	suite:case("separates the new section from earlier releases with one blank line", function(assert)
		local changelog = HEADER .. "\n\n" .. EARLIER_RELEASE .. "\n"

		assert.eq(prependSection(changelog, SECTION), EXPECTED_WITH_EARLIER_RELEASE)
	end)

	suite:case("collapses extra blank lines around the new section", function(assert)
		local changelog = HEADER .. "\n\n\n\n" .. EARLIER_RELEASE .. "\n\n\n"

		assert.eq(prependSection(changelog, SECTION), EXPECTED_WITH_EARLIER_RELEASE)
	end)

	suite:case("puts the section first when the changelog has no header", function(assert)
		assert.eq(prependSection(EARLIER_RELEASE .. "\n", SECTION), SECTION .. "\n\n" .. EARLIER_RELEASE .. "\n")
	end)
end)
