---
bump: minor
category: Fixes
---

`gate` publishes an untagged version only when `CHANGELOG.md` already contains its `## v<version>` section, so a fresh repo does not auto-publish whatever version sits in its manifest. The first release uses the version from `changewrite.toml` verbatim, folding the pending changes into it without bumping.
