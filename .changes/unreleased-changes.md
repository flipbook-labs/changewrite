---
bump: minor
category: Features
---

Assemble releases from unreleased-change files. Drop a markdown file under `.changes/` with `bump` and optional `category` frontmatter, and `prepare-pr` folds the pending entries into the version bump and changelog, replacing the git-cliff commit-message flow.

<details>
<summary>Migrating from the git-cliff flow</summary>

The changelog and version bump are now driven by entry files instead of commit messages, so a consuming repo needs to:

1. **Add a `.changes/` directory.** changewrite reads it by default; copy [its README](https://github.com/flipbook-labs/changewrite/blob/main/.changes/README.md) in to document the format for contributors, or point somewhere else with `unreleased_changes` in `changewrite.toml`.
2. **Add an entry per change-worthy PR.** Create a markdown file with `bump:` (`major`/`minor`/`patch`) and an optional `category:` in the frontmatter; the body becomes the changelog text. This replaces deriving the changelog from commit messages.
3. **Drop git-cliff.** Delete `cliff.toml` and remove `git-cliff` from your toolchain manifest (`rokit.toml`/`foreman.toml`) — changewrite no longer shells out to it.
4. **Remove the `bump` input** from your workflow's changewrite step. The bump is now the largest one across the pending entries; use `force-version` when you need to set an exact version by hand.
5. **(Optional) enforce entries.** Set `require-entry: true` on a pull request workflow to fail any PR that doesn't add an entry.

</details>
