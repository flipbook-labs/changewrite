# Change entries

This folder holds the unreleased changes for the next release. Each file describes one change: how big a version bump it warrants and what to say about it in the changelog. At release time [Changewrite](https://github.com/flipbook-labs/changewrite) combines every entry here into `CHANGELOG.md`, bumps the version, and deletes the entries it consumed.

## Adding an entry

Create a Luau file in this folder that returns the entry's fields. The filename is up to you — it only exists to make entries easy to browse — so name it after the change, e.g. `fix-release-permissions.luau`:

```luau
return {
	bump = "minor",
	category = "Features",
	summary = "Add support for Foo values so Bar can be Bazzed.",
	body = "Foo values need Bar 2.0 or newer.",
}
```

- **`bump`** (required) — how much to move the version: `"major"`, `"minor"`, or `"patch"`.
- **`category`** — the heading this entry appears under in the changelog. When `categories` is configured in `changewrite.luau`, every entry needs one from that list. Otherwise it's optional and defaults to `Changes`.
- **`summary`** (required) — one short sentence for the changelog, on one line and at most 140 characters (see Summary checks).
- **`body`** — more detail for readers who want it, written in Markdown. It renders in a collapsed `<details>` block under the summary, so the list stays scannable, and opens under Highlights and Breaking changes. In plain notes (see Release-notes fields), it renders as paragraphs under the summary's bullet instead, so the changelog reads well as plain text.

Changewrite runs the file to read its fields, so a field's value can be computed instead of written out. Write a body in whatever form reads best: a quoted string, a block string, or paragraphs joined with `table.concat` so they stay indented with the rest of the table:

```luau
return {
	bump = "patch",
	category = "Fixes",
	summary = "List every entry in a category, including the last one.",
	body = table.concat({
		"A category's last entry was missing from the release notes.",
		"Notes for releases published before this fix stay as they are.",
	}, "\n\n"),
}
```

An entry can use the `string`, `table`, `math`, and `utf8` libraries and a few basic functions such as `tostring`. It can't `require` other modules or reach `os`, `io`, or `process`, because `changewrite check` runs entries from pull requests, including ones from forks. `changewrite check` also rejects a field it doesn't know, and a category, kind, or flag outside the lists it allows.

### Release-notes fields

These are optional, except that `kind` is required once a repo configures kinds. A release whose entries use none of them, with no `release.md` and no `collapsed` setting, renders the same plain notes as before.

```luau
return {
	bump = "minor",
	category = "Features",
	kind = "Engine",
	highlight = "Embedded runtime",
	summary = "Add an embedded runtime so stories can be browsed inside a running experience.",
}
```

- **`kind`** — what the change touches, such as `Docs` or `Engine`, from the kinds configured in `changewrite.luau` (see Kinds and chips). Once a repo configures any kinds, every entry needs one. It renders as a chip in front of the entry. The chips mark where each entry starts, so release notes list entries without numbers, and an entry without a chip gets a bullet. Entries are listed in the order they merged, so kinds mix within a category.
- **`flags`** — what the change asks of readers: any of `Breaking`, `Deprecated`, and `Security`, written as a list such as `flags = { "Breaking", "Security" }`. Each renders as a chip after the kind chip. `Breaking` entries are gathered under a Breaking changes heading near the top instead of under their category, and the release gets a banner asking readers to act. A `Security` flag adds a banner recommending the update.
- **`highlight`** — a short title for a change worth a headline. The entry's summary and body appear under Highlights, and its category lists it by title. Level 1 and 2 headings in a body render as level 4 so they nest under the release.
- **`pr`** — the pull request number, such as `pr = 42`. Changewrite finds it from the squash commit that added the entry, so set it only when that commit doesn't name the right pull request, such as an entry backfilled later. Entries are listed in the order their pull requests merged, so an entry with `pr` sorts by when that pull request merged.

### Kinds and chips

Each kind is a table under `kind` in `changewrite.luau`. `text` is the chip's label, and `color` sets its border and dot:

```luau
return {
	kind = {
		Engine = { text = "Engine", color = "#7c5cff" },
	},
}
```

Pick `color` to read on a white page. The dark color mode gets a lighter version of it: the same hue and chroma, 0.16 lighter in OKLCH, with chroma reduced if the result is too saturated for sRGB. The label's color is a neutral that suits each color mode, and `textColor` overrides it. A `colorMode.light` or `colorMode.dark` table overrides `color` or `textColor` for that mode alone, such as a hand-picked dark color:

```luau
Engine = { text = "Engine", color = "#7c5cff", colorMode = { dark = { color = "#a28bff" } } },
```

The `Breaking`, `Deprecated`, and `Security` flags have built-in chips, and a table of the same shape under `flag`, such as `flag = { Breaking = { text = "Heads up" } }`, restyles one.

Chips are images, because GitHub strips CSS from release notes. Run `changewrite generate` after changing kinds or flag styles, and commit the images it writes to `assets/` in this folder. Each chip's files are named after it in lowercase, such as `kind-engine-light.svg` for the `Engine` kind, so restyling a chip rewrites the same files and past releases show the new look too. A chip removed from `changewrite.luau` keeps its files, because past releases still link to them. `changewrite check` fails while the chips don't match `changewrite.luau`.

### Summary checks

A summary is one line in a long list of changes, so `changewrite check` fails when a summary spans more than one line or runs past 140 characters. Set `maxSummaryLength` in `changewrite.luau` to change the limit:

```luau
return {
	maxSummaryLength = 120,
}
```

### Converting Markdown entries

Changewrite reads only Luau entries. `changewrite check --fix` converts each Markdown entry in this folder to Luau. The first paragraph of a Markdown entry becomes the summary and the rest becomes the `body`. A converted summary can still be too long, and `check` reports it.

### Release summary

An optional `release.md` in this folder opens the release notes with a TL;DR, written as plain Markdown:

```markdown
Flipbook now runs inside live experiences, and a shared link opens straight to the right stories.
```

Without one, the TL;DR lists the highlight titles. The file is consumed with the entries at release time.

### Collapsed categories

Categories listed in `collapsed` in `changewrite.luau` render inside a collapsed `<details>` block with their entry count, after the other categories:

```luau
return {
	categories = { "Features", "Fixes", "Dependencies", "Internal" },
	collapsed = { "Dependencies", "Internal" },
}
```

## How the version is chosen

The next version is the largest bump across all pending entries: a single `major` entry makes the release a major, otherwise a single `minor` makes it a minor, otherwise it's a `patch`. You don't pick the version yourself — you just say how big each change is.

## Notes

- `README.md` (this file) and the `assets/` folder are ignored, so they're safe to keep here.
- Entries are deleted once they're released; they live in this folder only while unreleased.
- The folder location is configurable via `unreleasedChanges` in `changewrite.luau` (it defaults to `./.changes/`).
- Run `changewrite check` to validate every pending entry before enforcing that a pull request adds an entry.
