---
bump: minor
category: Fixes
---

Bootstrap the first release of a repo correctly: `prepare-pr` now bumps the `0.0.0` placeholder to `0.1.0` (or `1.0.0` when a major change is pending) instead of preparing `0.0.0` itself, and `gate` never auto-publishes an untagged `0.0.0`.
