local path = require("@std/path")
local test = require("@std/test")

local renderRichChangelogSection = require("@root/release/notes/renderRichChangelogSection")
local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag
type ChangeKind = types.ChangeKind
type UnreleasedChange = types.UnreleasedChange

type EntryFields = {
	category: string?,
	kind: ChangeKind?,
	flags: { ChangeFlag }?,
	highlight: string?,
	pr: number?,
}

local REPO = "https://github.com/acme/widget"
local CHIPS = "https://raw.githubusercontent.com/flipbook-labs/changewrite/main/assets/chips/v1"

local function entry(body: string, fields: EntryFields): UnreleasedChange
	return {
		bump = "patch",
		category = fields.category or "Changes",
		body = body,
		kind = fields.kind,
		flags = fields.flags or {},
		highlight = fields.highlight,
		pr = fields.pr,
		file = path.parse(body),
	}
end

-- Written out by hand so the expected markup doesn't come from the renderer.
local function chip(name: string, label: string): string
	return `<picture><source media="(prefers-color-scheme: dark)" srcset="{CHIPS}/{name}-dark.svg">`
		.. `<source media="(prefers-color-scheme: light)" srcset="{CHIPS}/{name}-light.svg">`
		.. `<img src="{CHIPS}/{name}-light.png" alt="{label}" height="18" align="texttop"></picture>`
end

test.suite("renderRichChangelogSection", function(suite)
	suite:case("lays out a release from action to information", function(assert)
		local section = renderRichChangelogSection("2.0.0", {
			entry("Remove the old loader.", {
				category = "Features",
				kind = "breaking",
				highlight = "A new loader",
				pr = 9,
			}),
			entry("Fix a crash on reload.", { category = "Features", kind = "fixed", pr = 7 }),
			entry("Add an embedded runtime.", {
				category = "Features",
				kind = "new",
				flags = { "api" },
				highlight = "Embedded runtime",
				pr = 5,
			}),
			entry("Restructure CI.", { category = "Internal", kind = "improved", pr = 3 }),
		}, {
			categories = { "Features", "Internal" },
			collapsed = { "Internal" },
			summary = {
				file = path.parse("release.md"),
				name = "Out in the open",
				tldr = "Flipbook now runs outside Studio.",
			},
			repositoryUrl = REPO,
		})

		assert.eq(
			section,
			table.concat({
				"## v2.0.0",
				"",
				"<!-- release-name: Out in the open -->",
				"",
				"> [!WARNING]",
				"> Action required: this release has breaking changes. Each one under [Breaking changes](#breaking-changes) says what changed.",
				"",
				"Flipbook now runs outside Studio.",
				"",
				"1 new · 1 fixed · 1 breaking · 1 internal",
				"",
				"### Breaking changes",
				"",
				`1. {chip("breaking", "BREAKING")} **A new loader**`,
				"",
				`   Remove the old loader. ([#9]({REPO}/pull/9))`,
				"",
				"### Highlights",
				"",
				`> #### {chip("breaking", "BREAKING")} A new loader`,
				">",
				"> See [Breaking changes](#breaking-changes).",
				"",
				`> #### {chip("new", "NEW")} {chip("api", "API")} Embedded runtime`,
				">",
				`> Add an embedded runtime. ([#5]({REPO}/pull/5))`,
				"",
				"### Features",
				"",
				`1. {chip("new", "NEW")} {chip("api", "API")} Embedded runtime ([#5]({REPO}/pull/5))`,
				`2. {chip("fixed", "FIXED")} Fix a crash on reload. ([#7]({REPO}/pull/7))`,
				"",
				"<details>",
				"<summary>Internal (1)</summary>",
				"",
				`1. {chip("improved", "IMPROVED")} Restructure CI. ([#3]({REPO}/pull/3))`,
				"",
				"</details>",
			}, "\n")
		)
	end)

	suite:case("renders no banner when the release needs no action", function(assert)
		local section = renderRichChangelogSection("1.1.0", {
			entry("Add a thing.", { kind = "new" }),
		}, {
			collapsed = {},
		})

		assert.eq(
			section,
			table.concat({
				"## v1.1.0",
				"",
				"1 new",
				"",
				"### Changes",
				"",
				`1. {chip("new", "NEW")} Add a thing.`,
			}, "\n")
		)
	end)

	suite:case("recommends updating when an entry is flagged as a security fix", function(assert)
		local section = renderRichChangelogSection("1.0.1", {
			entry("Escape story names.", { kind = "fixed", flags = { "security" } }),
		}, {
			collapsed = {},
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

	suite:case("lists entries without a kind after those with one", function(assert)
		local section = renderRichChangelogSection("1.0.0", {
			entry("Plain.", {}),
			entry("Fixed.", { kind = "fixed" }),
			entry("Improved.", { kind = "improved" }),
		}, {
			collapsed = {},
		})

		local plainAt = section:find("Plain.", 1, true) :: number
		local fixedAt = section:find("Fixed.", 1, true) :: number
		local improvedAt = section:find("Improved.", 1, true) :: number
		assert.eq(improvedAt < fixedAt, true)
		assert.eq(fixedAt < plainAt, true)
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
				kind = "new",
				highlight = "A new API",
			}),
		}, {
			collapsed = {},
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
