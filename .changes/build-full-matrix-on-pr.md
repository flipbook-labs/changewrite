---
bump: patch
category: Internal
---

Build the full macOS/Linux/Windows matrix on every PR via a reusable `build.yml` workflow (`workflow_call`), which the release workflow now reuses with `upload-artifacts: true`. Windows stays non-blocking (`continue-on-error`) for now.
