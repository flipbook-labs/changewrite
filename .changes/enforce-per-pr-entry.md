---
bump: minor
category: Changes
---

`check` requires the current branch to add its own changelog entry, so `require-entry` enforces a changelog entry per PR. Workflows enabling it must check out with full history (`fetch-depth: 0`) so the check can compare against the base branch.
