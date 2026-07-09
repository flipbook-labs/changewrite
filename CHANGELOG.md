# Changelog

All notable changes to this project will be documented in this file.


## v0.7.0

### Changes

- `check` also counts an entry that exists only in the working tree, so it passes locally before the entry is committed.

### Dependencies

- Upgrade AgentSkills `v0.3.0` → `v0.4.0`.

### Features

- Add a `changewrite init` command that scaffolds a `changewrite.toml` from the version manifests it detects.

- Add a dedicated `flipbook-labs/changewrite/publish-lock` action (and `lock`/`unlock` CLI commands) that prevents the publish PR from being merged until the main branch settles.

### Internal

- Point the agent guide at the `org/review-pass` skill and fix how it resolves the pinned AgentSkills version.

- The release job now runs the binary it just built instead of downloading the last published release, so a new CLI feature takes effect on the release that introduces it rather than the one after.


## v0.6.0

### Changes

- `check` requires the current branch to add its own changelog entry. Workflows using `require-entry` must check out with full history (`fetch-depth: 0`).

### Dependencies

- Upgrade AgentSkills `v0.2.0` → `v0.3.0`.

- Upgrade FlipbookBatteries `v0.11.1` → `v0.12.0` and Lute `v1.0.1-nightly.20260612` → `v1.0.1-nightly.20260701`.

### Fixes

- `gate` publishes an untagged version only after `prepare-pr` records it as a `## v<version>` section in `CHANGELOG.md`, and the first release uses the `changewrite.toml` version verbatim without bumping.

### Internal

- Build and verify the macOS, Linux, and Windows binaries on every pull request.

- `AGENTS.md` now gates work behind mandatory first steps: bootstrap the toolchain, resolve the shared skills path, and read the skills index in full before writing anything. It also requires passing that bootstrap and the relevant `SKILL.md` paths to any subagent, since subagents do not inherit the guide.

- Upload the built macOS, Linux, and Windows binaries as artifacts on every pull request and release, so any run's binaries can be downloaded and checked.


## v0.5.0

### Changes

- Download the pre-built binary from the GitHub release instead of compiling from source on every action run. Removes the `rokit-version` input, which was only used internally to drive the build.

### Features

- Enhance the `check` command's error message to include a ready-to-adapt changelog entry template and guidance on the entry format, so users can write correct entries without leaving the terminal.

### Fixes

- Fall back to the latest release when the binary for the version in `changewrite.toml` isn't published yet. The publish PR bumps the version before its release exists, so pinning the download to that version left every publish PR's CI failing with "release not found".


## v0.4.0

### Changes

- Parse `changewrite.toml` with Lute's TOML battery instead of a hand-rolled parser, so comments, quoting, whitespace, and single inline-table mirrors are handled by a real TOML parser.

- Open the generated publish PR ready for review instead of as a draft.

### Features

- Assemble releases from unreleased-change files. Drop a markdown file under `.changes/` with `bump` and optional `category` frontmatter, and `prepare-pr` folds the pending entries into the version bump and changelog, replacing the git-cliff commit-message flow.

  <details>
  <summary>Migrating from the git-cliff flow</summary>

  The changelog and version bump are now driven by entry files instead of commit messages, so a consuming repo needs to:

  1. **Add a `.changes/` directory.** Changewrite reads it by default; copy [its README](https://github.com/flipbook-labs/changewrite/blob/main/.changes/README.md) in to document the format for contributors, or point somewhere else with `unreleased_changes` in `changewrite.toml`.
  2. **Add an entry per change-worthy PR.** Create a markdown file with `bump:` (`major`/`minor`/`patch`) and an optional `category:` in the frontmatter; the body becomes the changelog text. This replaces deriving the changelog from commit messages.
  3. **Drop git-cliff.** Delete `cliff.toml` and remove `git-cliff` from your toolchain manifest (`rokit.toml`/`foreman.toml`) — Changewrite no longer shells out to it.
  4. **Remove the `bump` input** from your workflow's Changewrite step. The bump is now the largest one across the pending entries; use `force-version` when you need to set an exact version by hand.
  5. **(Optional) enforce entries.** Set `require-entry: true` on a pull request workflow to fail any PR that doesn't add an entry.

  </details>

### Fixes

- Skip the `require-entry` changelog check on the publish PR, which has no `.changes/` entry of its own to find.


## v0.3.0

### Changes

- Clear existing rokit auth before setup-rokit runs (#21) ([d508ba3](https://github.com/flipbook-labs/changewrite/commit/d508ba3c95489268dd1c4488cb89bc1acfd5b206))

- Add a bump escape hatch and auto-recover from burned tags (#23) ([50378bf](https://github.com/flipbook-labs/changewrite/commit/50378bf7f797b1217304ee40282ed50fc94b8374))



## v0.2.0

### Changes

- Upgrade Lute and FlipbookBatteries (#20) ([d7a9291](https://github.com/flipbook-labs/changewrite/commit/d7a92919f09245d277e69eb4e6145186c01c22d3))

- Install the action's own toolchain instead of the consumer's (#18) ([78c66b0](https://github.com/flipbook-labs/changewrite/commit/78c66b0c4e41b7bae26c6c1aa75d34c79587967c))



## v0.1.0

### Changes

- Introduce a fallback to HEAD for the release commit (#17) ([00acc0c](https://github.com/flipbook-labs/changewrite/commit/00acc0c6bdabecc1d5bfd17a42240c2ac64de18c))

- Fix release 403 and hoist app token out of the action (#13) ([2e9817d](https://github.com/flipbook-labs/changewrite/commit/2e9817d3e767f14917ef350b04155a5fd9398e72))

- Create release tag via GitHub API instead of git push (#11) ([e9516ca](https://github.com/flipbook-labs/changewrite/commit/e9516caae31f1db6d09f7708f833bddbeb316ccf))

- Fix: add workflows:write permission to release job (#10) ([4e6be80](https://github.com/flipbook-labs/changewrite/commit/4e6be80fc90f6ee02125bcc283d451f68a815d7b))

- Name release artifacts after their zip files (#9) ([4465a95](https://github.com/flipbook-labs/changewrite/commit/4465a95ff9a0af46cd884687e71a32ece4dd7d1a))

- Fix tag push rejection caused by missing workflows permission on app token (#7) ([7e0df24](https://github.com/flipbook-labs/changewrite/commit/7e0df240d7e4982b2061f3170125396dc8e1d8c3))

- Fix template parse error from literal ${{ }} in hook descriptions (#6) ([227634f](https://github.com/flipbook-labs/changewrite/commit/227634fa996e64b052856bc9e56ca5da89283e3f))

- Revert "Fix template parse error from literal ${{ }} in hook descriptions" ([6ff0986](https://github.com/flipbook-labs/changewrite/commit/6ff09867734baaaa06d158e52e27a4b321ff6165))

- Fix template parse error from literal ${{ }} in hook descriptions ([8a16b8d](https://github.com/flipbook-labs/changewrite/commit/8a16b8dac5f16268a9fc6ec649b86bc71603885f))

- Add release hooks to consolidate attach/publish jobs (#5) ([13413b7](https://github.com/flipbook-labs/changewrite/commit/13413b7a002a1edfecd8dea1e764d306953bfa45))

- Use the right secrets (#3) ([6bf6328](https://github.com/flipbook-labs/changewrite/commit/6bf632891e982387e50c8697b55830e4ef3021a2))

- Dogfood changewrite action in release workflow (#2) ([6eaa977](https://github.com/flipbook-labs/changewrite/commit/6eaa97786c1b3451e6dbc58581ac3e36ab69b421))

- Nuke the agent-generated README (#1) ([cb72c4a](https://github.com/flipbook-labs/changewrite/commit/cb72c4af3a2df350fa78f230ecebafd199153815))

- Collapse release command group onto the main CLI ([83b8834](https://github.com/flipbook-labs/changewrite/commit/83b8834cd97e214545f74e284ba1358fe30ad2ed))

- Initial commit ([342af9e](https://github.com/flipbook-labs/changewrite/commit/342af9eaa6115539c23f182162ad94a58af33570))
