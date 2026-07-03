---
bump: patch
category: Fixes
---

Fall back to the latest release when the binary for the version in `changewrite.toml` isn't published yet. The publish PR bumps the version before its release exists, so pinning the download to that version left every publish PR's CI failing with "release not found".
