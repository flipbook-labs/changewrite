---
bump: minor
category: Features
---

Assemble releases from change partials. Drop a markdown file under `.changes/` with `bump` and optional `category` frontmatter, and `prepare-pr` folds the pending entries into the version bump and changelog, replacing the git-cliff commit-message flow.
