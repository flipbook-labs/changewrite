---
bump: patch
category: Internal
---

Guard the publish PR with a `publish-lock` commit status that fails while a release run is regenerating it, so it cannot be merged mid-update.
