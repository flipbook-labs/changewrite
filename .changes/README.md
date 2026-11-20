# Change entries

This folder holds the unreleased changes for the next release. Each file describes one change: how big a version bump it warrants and what to say about it in the changelog. At release time [Changewrite](https://github.com/flipbook-labs/changewrite) combines every entry here into `CHANGELOG.md`, bumps the version, and deletes the entries it consumed.

## Adding an entry

Create a Luau file in this folder that returns the entry's fields. The filename is up to you — it only exists to make entries easy to browse — so name it after the change, e.g. `fix-release-permissions.luau`:

```luau
return {
	bump = "minor",
	category = "Features",
	summary = "Add support for Foo values so Bar can be Bazzed.",
	description = [[
Foo values need Bar 2.0 or newer.
]],
}
```

- **`bump`** (required) — how much to move the version: `"major"`, `"minor"`, or `"patch"`.
- **`category`** — the heading this entry appears under in the changelog. When `categories` is configured in `changewrite.toml`, every entry needs one from that list. Otherwise it's optional and defaults to `Changes`.
- **`summary`** (required) — one short sentence for the changelog, at most 140 characters, written as a quoted string.
- **`description`** — more detail for readers who want it, written as a block string. It renders after the summary.

Changewrite reads the table without running the file, so every value has to be a literal. `changewrite check` rejects a field it doesn't know, and a category, kind, or flag outside the lists it allows.

### Release-notes fields

These are optional, except that `kind` is required once a repo configures kinds. A release whose entries use none of them, with no `release.md` and no `collapsed` setting, renders the same plain notes as before.

```luau
return {
	bump = "minor",
	category = "Features",
	kind = "engine",
	highlight = "Embedded runtime",
	summary = "Add an embedded runtime so stories can be browsed inside a running experience.",
}
```

- **`kind`** — what the change touches, such as `docs` or `engine`, from the kinds configured in `changewrite.toml` (see Kinds and chips). Once a repo configures any kinds, every entry needs one. It renders as a chip in front of the entry. Entries are listed in the order they merged, so kinds mix within a category.
- **`flags`** — what the change asks of readers: any of `breaking`, `deprecated`, and `security`, written as a list such as `flags = { "breaking", "security" }`. Each renders as a chip after the kind chip. `breaking` entries are gathered under a Breaking changes heading near the top instead of under their category, and the release gets a banner asking readers to act. A `security` flag adds a banner recommending the update.
- **`highlight`** — a short title for a change worth a headline. The entry's summary and description appear under Highlights, and its category lists it by title. Level 1 and 2 headings in a description render as level 4 so they nest under the release.
- **`pr`** — the pull request number, such as `pr = 42`. Changewrite finds it from the squash commit that added the entry, so set it only when that commit doesn't name the right pull request, such as an entry backfilled later. Entries are listed in the order their pull requests merged, so an entry with `pr` sorts by when that pull request merged.

### Kinds and chips

Each kind is a table in `changewrite.toml`. `text` is the chip's label, and `color` sets its border and dot:

```toml
[kind.engine]
text = "Engine"
color = "#7c5cff"
```

Pick `color` to read on a white page. The dark color mode gets a lighter version of it: the same hue and chroma, 0.16 lighter in OKLCH, with chroma reduced if the result is too saturated for sRGB. The label's color is a neutral that suits each color mode, and `textColor` overrides it. A `colorMode.light` or `colorMode.dark` table overrides `color` or `textColor` for that mode alone, such as a hand-picked dark color:

```toml
[kind.engine.colorMode.dark]
color = "#a28bff"
```

The `breaking`, `deprecated`, and `security` flags have built-in chips, and a `[flag.<name>]` table of the same shape restyles one.

Chips are images, because GitHub strips CSS from release notes. Run `changewrite generate` after changing kinds or flag styles, and commit the images it writes to `assets/` in this folder. Each chip's files are named after it, such as `kind-engine-light.svg`, so restyling a chip rewrites the same files and past releases show the new look too. A chip removed from `changewrite.toml` keeps its files, because past releases still link to them. `changewrite check` fails while the chips don't match `changewrite.toml`.

### Lint rules

`changewrite check` runs these rules over every entry:

- `changewrite_summary_length` — the summary is at most 140 characters. Its `max_length` option changes the limit.
- `changewrite_summary_string` — the summary is a plain quoted string on one line, not a block string or an interpolated one.
- `changewrite_description_string` — the description, when there is one, is a block string.

The same rules run under `lute lint`, so a repo can run them next to its other lint rules. Add Changewrite to `pkg.luau` as a dev dependency, run `lute pkg install --vendor`, then point `lute lint` at the rules folder in `.lpm`:

```sh
lute lint --rules .lpm/changewrite@<rev>/src/entries/rules .changes
```

A Lute script can require the package and pass `ENTRY_RULES_PATH` instead of writing out the folder. Set rule options and turn rules off in `.config.luau`, where `changewrite check` reads them too:

```luau
return {
	lute = {
		lint = {
			ruleconfigs = {
				changewrite_summary_length = { options = { max_length = 120 } },
			},
		},
	},
}
```

### Converting Markdown entries

Changewrite reads only Luau entries. `changewrite check --fix` converts each Markdown entry in this folder to Luau. The first paragraph of a Markdown body becomes the summary and the rest becomes the description, so the entry renders the same. A converted summary can still be too long, and `check` reports it.

### Release summary

An optional `release.md` in this folder opens the release notes with a TL;DR, written as plain Markdown:

```markdown
Flipbook now runs inside live experiences, and a shared link opens straight to the right stories.
```

Without one, the TL;DR lists the highlight titles. The file is consumed with the entries at release time.

### Collapsed categories

Categories listed in `collapsed` in `changewrite.toml` render inside a collapsed `<details>` block with their entry count, after the other categories:

```toml
categories = ["Features", "Fixes", "Dependencies", "Internal"]
collapsed = ["Dependencies", "Internal"]
```

## How the version is chosen

The next version is the largest bump across all pending entries: a single `major` entry makes the release a major, otherwise a single `minor` makes it a minor, otherwise it's a `patch`. You don't pick the version yourself — you just say how big each change is.

## Notes

- `README.md` (this file) and the `assets/` folder are ignored, so they're safe to keep here.
- Entries are deleted once they're released; they live in this folder only while unreleased.
- The folder location is configurable via `unreleased_changes` in `changewrite.toml` (it defaults to `./.changes/`).
- Run `changewrite check` to validate every pending entry before enforcing that a pull request adds an entry.
