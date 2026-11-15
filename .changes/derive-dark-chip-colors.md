---
bump: minor
category: Changes
---

A chip with only a `color` now gets a lighter version of it in the dark color mode, instead of the same color. A `colorMode.dark` color still overrides it. The `breaking` and `deprecated` flags' dark colors change slightly to match the rule, so run `changewrite generate` after upgrading.
