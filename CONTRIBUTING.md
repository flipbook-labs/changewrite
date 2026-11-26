# Contributing to Changewrite

## Setup

Changewrite uses [Rokit](https://github.com/rojo-rbx/rokit) for toolchain management.

```sh
rokit install
lute run install   # vendor dependencies into .lpm/
lute run analyze   # run the stylua, CodeQuality lint, and luau-lsp checks
lute run build     # compile the changewrite binary into build/
lute test          # run the *.spec.luau test suite
```

`lute run install` copies the dependencies into `.lpm/<key>@<rev>` folders, and code requires them through the `lpm` alias in `.config.luau`, which `lute compile` bundles into the binary. It also fetches the shared [agent-skills](https://github.com/flipbook-labs/agent-skills) library that [`AGENTS.md`](AGENTS.md) routes agents to. That library is a dev dependency, so it lands in `.lpm/` but is not bundled into the binary.

## Changelog entries

Each pull request adds one entry under `.changes/`, as described in [`.changes/README.md`](.changes/README.md). Changewrite releases itself, so merging the publish PR it keeps open cuts the next version.
