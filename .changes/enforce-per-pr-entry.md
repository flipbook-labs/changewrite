---
bump: minor
category: Changes
---

`check` (used by the `require-entry` action input) now fails unless the current branch adds a **new** changelog entry compared to its base ref, instead of merely confirming that some entry already exists. It diffs the unreleased-changes directory against a base ref (`--base`, `$CHANGEWRITE_BASE_REF`, defaulting to `origin/main`). Consumers enabling `require-entry` must check out with full history (`fetch-depth: 0`).
