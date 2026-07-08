---
bump: minor
category: Fixes
---

`gate` publishes an untagged version only after `prepare-pr` records it as a `## v<version>` section in `CHANGELOG.md`, and the first release uses the `changewrite.toml` version verbatim without bumping.
