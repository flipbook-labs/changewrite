# Changewrite agent guide

Changewrite is a CLI tool and GitHub Action for release automation: it creates release PRs, drafts and publishes GitHub releases, and exposes release state for downstream jobs. It is written in Luau, runs on Lute, and compiles to a native binary. This file is the entry point for any agent working in the repo. It routes you to the shared skills library and the repo's own setup.

## Mandatory first steps

Complete every step below before you write any code, tests, changelog entries, or PR prose. This is a gate, and it does not depend on how you classify your task.

1. Install the toolchain and dependencies:

   ```sh
   rokit install && lute run install
   ```

   `rokit install` puts `lute`, `luau-lsp`, `stylua`, and `selene` on PATH. `lute run install` fetches the Loom dependencies into `~/.loom/store` and vendors them into `packages/`. The shared skills library is a dev dependency, so it lands in `~/.loom/store` for you to read but is not bundled into the binary. Without this step the skills are not on disk.

2. Resolve the concrete skills path (do not guess the version):

   ```sh
   ls -d ~/.loom/store/AgentSkills@*
   ```

   That prints the one installed copy, for example `~/.loom/store/AgentSkills@v0.2.0`. Use the printed path wherever `<skills>` appears below. The version tracks the `rev` pinned for `AgentSkills` in [`loom.config.luau`](loom.config.luau).

3. Read the routing index at `<skills>/AGENTS.md` in full. Its **Project Skills** section lists every skill with a trigger-rich one-liner, so you know what exists before you start. This read is unconditional.

Deep reads of individual `<skills>/src/<scope>/<name>/SKILL.md` files stay on demand: when a task matches a trigger from the index, read that skill before doing the work it covers. Reading the index up front is what lets those triggers fire.

## Subagents do not inherit this file

The Task tool spawns subagents in a fresh context that does not include this guide. Whenever you delegate to a subagent, you MUST include in its prompt:

1. The mandatory first steps above (the bootstrap command and the index read).
2. The concrete resolved path(s) to the specific `SKILL.md` files relevant to its task.

Never assume a subagent will discover the skills on its own.

## Keeping skills current

Skills are living documents. If your work here contradicts a skill (a renamed symbol, a changed value, a fixed bug it still calls known), fix it in the agent-skills repo and add a `.changes/` entry there in the same PR. The fix reaches this repo on its next `rev` bump.

## Repo specifics

- Toolchain is managed with [Rokit](https://github.com/rojo-rbx/rokit). Run `rokit install` once to get `lute`, `luau-lsp`, `stylua`, and `selene` on PATH.
- `lute run --list` shows the available scripts: `install` (set up dependencies), `analyze` (stylua and luau-lsp checks), and `build` (compile the `changewrite` binary into `build/`).
- Tests are `*.spec.luau` files alongside the code they cover. Run the suite with `lute test`.
- The GitHub Action is defined in [`action.yml`](action.yml). The CLI entry point is [`cli.luau`](cli.luau), which dispatches into [`src/cli/`](src/cli). The release logic it drives lives in [`src/release/`](src/release).
- Changewrite manages its own changelog the way it manages others': unreleased entries live as partials in [`.changes/`](.changes) and are assembled into [`CHANGELOG.md`](CHANGELOG.md) at release time. Add a `.changes/` entry for any user-facing change.
