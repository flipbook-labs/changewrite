---
bump: patch
category: Fixes
---

`check` reads the base branch from GitHub Actions when `origin/HEAD` is missing, and passes on the base branch itself.
