---
bump: patch
---

Parse `changewrite.toml` with Lute's TOML battery instead of a hand-rolled parser, so comments, quoting, whitespace, and single inline-table mirrors are handled by a real TOML parser.
