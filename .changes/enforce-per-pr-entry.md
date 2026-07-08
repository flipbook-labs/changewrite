---
bump: minor
category: Changes
---

`check` (used by the `require-entry` action input) fails unless the current branch adds a new changelog entry under the unreleased-changes directory, enforcing a changelog entry per PR. It compares against a base ref (`--base`, `$CHANGEWRITE_BASE_REF`, defaulting to `origin/main`), so consumers enabling `require-entry` must check out with full history (`fetch-depth: 0`).
