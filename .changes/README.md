# Change entries

This folder holds the unreleased changes for the next release. Each file describes one change: how big a version bump it warrants and what to say about it in the changelog. At release time [Changewrite](https://github.com/flipbook-labs/changewrite) combines every entry here into `CHANGELOG.md`, bumps the version, and deletes the entries it consumed.

## Adding an entry

Create a markdown file in this folder. The filename is up to you — it only exists to make entries easy to browse — so name it after the change, e.g. `fix-release-permissions.md`:

```markdown
---
bump: minor
category: Features
---

Add support for Foo values so Bar can be Bazzed.
```

- **`bump`** (required) — how much to move the version: `major`, `minor`, or `patch`.
- **`category`** (optional) — the heading this entry appears under in the changelog. When `categories` is configured in `changewrite.toml`, the value must come from that list. Defaults to `Changes`.
- **Body** — everything below the frontmatter is the changelog text. Aim for one or two sentences; it can span multiple paragraphs if a change needs it.

### Release-notes fields

These are optional. A release whose entries use none of them, with no `release.md` and no `collapsed` setting, renders the same plain notes as before.

```markdown
---
bump: minor
category: Features
kind: new
flags: api
highlight: Embedded runtime
---

Add an embedded runtime so stories can be browsed inside a running experience.
```

- **`kind`** — what kind of change it is: `new`, `improved`, `fixed`, or `breaking`. It renders as a chip in front of the entry, and entries are sorted by kind within their category. `breaking` entries are gathered under a Breaking changes heading near the top instead of under their category, and the release gets a banner asking readers to act.
- **`flags`** — extra chips for who should look: any of `api`, `deprecated`, and `security`, written as `flags: api, security`. A `security` flag adds a banner recommending the update.
- **`highlight`** — a short title for a change worth a headline. The entry's full body appears under Highlights, and its category lists it by title. Level 1 and 2 headings in a body render as level 4 so they nest under the release.
- **`pr`** — the pull request number. Changewrite finds it from the squash commit that added the entry, so set it only when that commit doesn't name the right pull request.

### Release summary

An optional `release.md` in this folder opens the release notes with a TL;DR. Its frontmatter can set a `name`, which becomes part of the GitHub release title:

```markdown
---
name: Out in the open
---

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

- `README.md` (this file) is ignored, so it's safe to keep here.
- Entries are deleted once they're released; they live in this folder only while unreleased.
- The folder location is configurable via `unreleased_changes` in `changewrite.toml` (it defaults to `./.changes/`).
- Run `changewrite check` to validate every pending entry before enforcing that a pull request adds an entry.
