---
bump: minor
category: Features
---

Add a dedicated `flipbook-labs/changewrite/publish-lock` action (and `lock`/`unlock` CLI commands) that guards the publish PR with a `publish-lock` commit status: it locks the PR while a release run regenerates it, so it cannot be merged out of date, and unlocks it once the PR is up to date again.
