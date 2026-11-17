---
bump: patch
category: Changes
kind: tooling
---

Build Changewrite from a `pkg.luau` manifest on Lute 1.0.1-nightly.20261115. The build copies dependencies from the Loom store into `build/` and bundles them from there, so it works wherever the checkout is.
