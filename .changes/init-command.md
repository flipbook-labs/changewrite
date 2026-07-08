---
bump: minor
category: Features
---

Add a `changewrite init` command that scaffolds a `changewrite.toml`. It detects Loom, Wally, Cargo, Rotriever, and npm manifests, wires each as a version mirror, and inherits the current version (the highest when they disagree, `0.1.0` when none exists). It refuses to overwrite an existing `changewrite.toml`.
