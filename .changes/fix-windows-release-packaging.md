---
bump: patch
category: Internal
---

Package and upload the built binaries as artifacts on every build, both on pull requests and in the release workflow, so PR binaries can be inspected and the release ships its own copies. Windows now packages with PowerShell's `Compress-Archive` since Windows runners have no `zip`.
