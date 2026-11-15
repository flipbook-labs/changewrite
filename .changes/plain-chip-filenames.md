---
bump: minor
category: Changes
---

Name chip images after their kind or flag, such as `kind-engine-light.svg`, and drop `lock.json`. Restyling a chip now rewrites the same files, so past releases show the new look too. After upgrading, run `changewrite generate`, then delete `lock.json` and the old hashed chip files from the assets folder.
