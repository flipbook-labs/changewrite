local path = require("@std/path")
local test = require("@std/test")

local notesTypes = require("@root/release/notes/types")
local renderRichChangelogSection = require("@root/release/notes/renderRichChangelogSection")
local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag
type UnreleasedChange = types.UnreleasedChange

type EntryFields = {
	category: string?,
	kind: string?,
	flags: { ChangeFlag }?,
	highlight: string?,
	pr: number?,
}

local REPO = "https://github.com/acme/widget"

-- Stand-in markup, so the expected layout stays readable. `renderChip` has its
-- own spec for the real markup.
local CHIPS: notesTypes.ChipMarkup = {
	["kind/docs"] = "[docs]",
	["kind/engine"] = "[engine]",
	["kind/ui"] = "[ui]",
	["flag/Breaking"] = "[breaking]",
	["flag/Deprecated"] = "[deprecated]",
	["flag/Security"] = "[security]",
}

local function entry(body: string, fields: EntryFields): UnreleasedChange
	return {
		bump = "patch",
		category = fields.category or "Changes",
		summary = body,
		body = body,
		kind = fields.kind,
		flags = fields.flags or {},
		highlight = fields.highlight,
		pr = fields.pr,
		file = path.parse(body),
	}
end

test.suite("renderRichChangelogSection", function(suite)
	suite:case("lays out a release from action to information", function(assert)
		local section = renderRichChangelogSection("2.0.0", {
			entry("Remove the old loader.", {
				category = "Features",
				kind = "engine",
				flags = { "Breaking" },
				highlight = "A new loader",
				pr = 9,
			}),
			entry("Add an embedded runtime.", {
				category = "Features",
				kind = "engine",
				highlight = "Embedded runtime",
				pr = 5,
			}),
			entry("Add a docs page.", { category = "Features", kind = "docs", pr = 6 }),
			entry("Fix a crash on reload.", { category = "Fixes", kind = "ui", pr = 7 }),
			entry("Restructure CI.", { category = "Internal", pr = 3 }),
		}, {
			categories = { "Features", "Fixes", "Internal" },
			collapsed = { "Internal" },
			summary = {
				file = path.parse("release.md"),
				tldr = "Flipbook now runs outside Studio.",
			},
			repositoryUrl = REPO,
			chips = CHIPS,
		})

		assert.eq(
			section,
			table.concat({
				"## v2.0.0",
				"",
				"> [!WARNING]",
				"> Action required: this release has breaking changes. Each one under [Breaking changes](#breaking-changes) says what changed.",
				"",
				"Flipbook now runs outside Studio.",
				"",
				"Breaking 1 · Features 2 · Fixes 1 · Internal 1",
				"",
				"### Breaking changes",
				"",
				"1. [engine] [breaking] **A new loader**",
				"",
				`   Remove the old loader. ([#9]({REPO}/pull/9))`,
				"",
				"### Highlights",
				"",
				"> [engine] [breaking] **A new loader**",
				">",
				"> See [Breaking changes](#breaking-changes).",
				"",
				"> [engine] **Embedded runtime**",
				">",
				`> Add an embedded runtime. ([#5]({REPO}/pull/5))`,
				"",
				"### Features",
				"",
				`1. [engine] Embedded runtime ([#5]({REPO}/pull/5))`,
				`2. [docs] Add a docs page. ([#6]({REPO}/pull/6))`,
				"",
				"### Fixes",
				"",
				`1. [ui] Fix a crash on reload. ([#7]({REPO}/pull/7))`,
				"",
				"<details>",
				"<summary>Internal (1)</summary>",
				"",
				`1. Restructure CI. ([#3]({REPO}/pull/3))`,
				"",
				"</details>",
			}, "\n")
		)
	end)

	suite:case("renders no banner when the release needs no action", function(assert)
		local section = renderRichChangelogSection("1.1.0", {
			entry("Add a thing.", { kind = "engine" }),
		}, {
			collapsed = {},
			chips = CHIPS,
		})

		assert.eq(
			section,
			table.concat({
				"## v1.1.0",
				"",
				"Changes 1",
				"",
				"### Changes",
				"",
				"1. [engine] Add a thing.",
			}, "\n")
		)
	end)

	suite:case("recommends updating when an entry is flagged as a security fix", function(assert)
		local section = renderRichChangelogSection("1.0.1", {
			entry("Escape story names.", { kind = "ui", flags = { "Security" } }),
		}, {
			collapsed = {},
			chips = CHIPS,
		})

		assert.eq(section:find("> [!IMPORTANT]\n> Update recommended", 1, true) ~= nil, true)
		assert.eq(section:find("[!WARNING]", 1, true), nil)
	end)

	suite:case("builds the TL;DR from highlight titles when there is no summary", function(assert)
		local section = renderRichChangelogSection("1.2.0", {
			entry("One.", { highlight = "Alpha" }),
			entry("Two.", { highlight = "Beta" }),
			entry("Three.", { highlight = "Gamma" }),
		}, {
			collapsed = {},
		})

		assert.eq(section:find("\n\nHighlights: Alpha, Beta, and Gamma.\n\n", 1, true) ~= nil, true)
	end)

	suite:case("keeps a category's entries in the order given, whatever their kind", function(assert)
		local section = renderRichChangelogSection("1.0.0", {
			entry("Plain.", {}),
			entry("Engine.", { kind = "engine" }),
			entry("Docs.", { kind = "docs" }),
		}, {
			collapsed = {},
			chips = CHIPS,
		})

		local plainAt = section:find("Plain.", 1, true) :: number
		local engineAt = section:find("Engine.", 1, true) :: number
		local docsAt = section:find("Docs.", 1, true) :: number
		assert.eq(plainAt < engineAt, true)
		assert.eq(engineAt < docsAt, true)
	end)

	suite:case("names the command to run when a chip hasn't been generated", function(assert)
		local success, err = pcall(function()
			return renderRichChangelogSection("1.0.0", {
				entry("Add a thing.", { kind = "engine" }),
			}, {
				collapsed = {},
			})
		end)

		assert.eq(success, false)
		assert.neq(string.find(tostring(err), "changewrite generate", 1, true), nil)
	end)

	suite:case("links a pull request by number when the repository is unknown", function(assert)
		local section = renderRichChangelogSection("1.0.0", {
			entry("Fix it.", { pr = 12 }),
		}, {
			collapsed = {},
		})

		assert.eq(section:find("1. Fix it. (#12)", 1, true) ~= nil, true)
	end)
	suite:case("keeps a heading in an entry body from ending the release", function(assert)
		local section = renderRichChangelogSection("1.0.0", {
			entry("Add a new API.\n\n## Migration\n\nCall the new one.", {
				kind = "engine",
				highlight = "A new API",
			}),
		}, {
			collapsed = {},
			chips = CHIPS,
			summary = {
				file = path.parse("release.md"),
				tldr = "A big one.\n\n## Why",
			},
		})

		assert.eq(section:find("\n## ", 1, true), nil)
		assert.neq(section:find("> #### Migration", 1, true), nil)
		assert.neq(section:find("#### Why", 1, true), nil)
	end)
end)
