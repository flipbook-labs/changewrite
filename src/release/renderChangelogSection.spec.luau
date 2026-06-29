local test = require("@std/test")

local changePartials = require("@root/release/changePartials")
local renderChangelogSection = require("@root/release/renderChangelogSection")

type Partial = changePartials.Partial

local function partial(bump: "major" | "minor" | "patch", category: string, body: string): Partial
	return { bump = bump, category = category, body = body, file = body }
end

test.suite("renderChangelogSection", function(suite)
	suite:case("groups entries under sorted category headings", function(assert)
		local section = renderChangelogSection("0.4.0", {
			partial("minor", "Features", "Add change partials."),
			partial("patch", "Dependencies", "Upgrade Lute."),
		})

		assert.eq(
			section,
			table.concat({
				"## v0.4.0",
				"",
				"### Dependencies",
				"",
				"- Upgrade Lute.",
				"",
				"### Features",
				"",
				"- Add change partials.",
			}, "\n")
		)
	end)

	suite:case("keeps multiple entries in the same category", function(assert)
		local section = renderChangelogSection("1.0.0", {
			partial("patch", "Changes", "First."),
			partial("patch", "Changes", "Second."),
		})

		assert.eq(
			section,
			table.concat({
				"## v1.0.0",
				"",
				"### Changes",
				"",
				"- First.",
				"",
				"- Second.",
			}, "\n")
		)
	end)

	suite:case("indents multi-line bodies under the bullet", function(assert)
		local section = renderChangelogSection("1.0.0", {
			partial("minor", "Changes", "First paragraph.\n\nSecond paragraph."),
		})

		assert.eq(
			section,
			table.concat({
				"## v1.0.0",
				"",
				"### Changes",
				"",
				"- First paragraph.",
				"",
				"  Second paragraph.",
			}, "\n")
		)
	end)

	suite:case("strips a leading v from the version", function(assert)
		local section = renderChangelogSection("v2.1.0", {
			partial("patch", "Changes", "Hi."),
		})

		assert.eq(section:match("^## (%S+)"), "v2.1.0")
	end)
end)
