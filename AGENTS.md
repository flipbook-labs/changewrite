# Changewrite agent guide

Changewrite is a CLI tool and GitHub Action for release automation: it creates
release PRs, drafts and publishes GitHub releases, and exposes release state for
downstream jobs. It is written in Luau, runs on Lute, and compiles to a native
binary. This file is the entry point for any agent working in the repo. It routes
you to the shared skills library and the repo's own setup.

## First: install dependencies

Before doing anything else in a fresh checkout, run:

```sh
rokit install
lute run install
```

`rokit install` puts the toolchain (`lute`, `luau-lsp`, `stylua`, `selene`) on
PATH. `lute run install` fetches the Loom (Lute) dependencies into `~/.loom/store`
and vendors them into `packages/` so they can be bundled into the compiled binary.
Without it the shared skills below are not on disk and analysis will not resolve.

## Shared skills: flipbook-labs/agent-skills

Cross-cutting doctrine (test discipline, code comments, changelog entries, writing
style) does not live in this repo. It lives in the org's shared, versioned
[AgentSkills](https://github.com/flipbook-labs/agent-skills) library, pinned in
[`loom.config.luau`](loom.config.luau) and installed by `lute run install` into:

```
~/.loom/store/AgentSkills@v0.2.0/
```

The version in that path tracks the `rev` pinned for `AgentSkills` in
`loom.config.luau`. When you bump the pin, the folder name changes to match.

Routing is manual and on demand, the same as the library's own convention:

1. Read the library's routing index at
   `~/.loom/store/AgentSkills@v0.2.0/AGENTS.md`. Its **Project Skills** section
   lists every skill with a trigger-rich one-liner.
2. When a task matches a trigger, read that skill's
   `~/.loom/store/AgentSkills@v0.2.0/src/<scope>/<name>/SKILL.md` before you start
   the work it covers.

Skills are living documents. If your work in this repo contradicts a skill (a
renamed symbol, a changed value, a fixed bug it still calls known), fix it in the
agent-skills repo and add a `.changes/` entry there in the same PR. The fix reaches
this repo on its next `rev` bump.

## Repo specifics

- Toolchain is managed with [Rokit](https://github.com/rojo-rbx/rokit); run
  `rokit install` once to get `lute`, `luau-lsp`, `stylua`, and `selene` on PATH.
- `lute run --list` shows the available scripts: `install` (set up dependencies),
  `analyze` (stylua and luau-lsp checks), and `build` (compile the `changewrite`
  binary into `build/`).
- Tests are `*.spec.luau` files alongside the code they cover; run the suite with
  `lute test`.
- The GitHub Action is defined in [`action.yml`](action.yml). The CLI entry point
  is [`cli.luau`](cli.luau), which dispatches into [`src/cli/`](src/cli); the
  release logic it drives lives in [`src/release/`](src/release).
- Changewrite manages its own changelog the way it manages others': unreleased
  entries live as partials in [`.changes/`](.changes) and are assembled into
  [`CHANGELOG.md`](CHANGELOG.md) at release time. Add a `.changes/` entry for any
  user-facing change.
