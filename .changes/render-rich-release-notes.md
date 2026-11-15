---
bump: minor
category: Features
---

Render richer release notes from `kind`, `flags`, `highlight`, and `pr` entry fields, a `release.md` summary, and `collapsed` categories. Kinds are configured per repo, and `changewrite generate` draws their chips. Once a repo configures categories or kinds, every entry has to pick one of each. GitHub release notes, rich or plain, now start their headings at level 1, since the release title already names the version.
