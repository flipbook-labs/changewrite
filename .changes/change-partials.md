---
bump: minor
category: Features
---

Assemble releases from change partials. Drop a markdown file under `.changes/` (configurable via `change_partials`) with `bump` and optional `category` frontmatter; `prepare-pr` now computes the version from the cumulative bump of those entries and folds them into the changelog, replacing the git-cliff commit-message flow.
