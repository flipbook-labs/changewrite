# changewrite

Changewrite is a CLI tool and GitHub Action for release automation: it creates release PRs, drafts and publishes GitHub releases, and exposes release state for downstream jobs.

## Changelog entries

Each change is a Luau file in `.changes/` that returns its fields, and Changewrite assembles them into `CHANGELOG.md` and the release notes. [`.changes/README.md`](.changes/README.md) describes the format and the lint rules that `changewrite check` and `lute lint` run over every entry.

## Development

Changewrite uses [Rokit](https://github.com/rojo-rbx/rokit) for toolchain management.

```sh
rokit install
lute run install   # vendor dependencies into .lpm/
lute run analyze   # run the stylua and luau-lsp checks
lute run build     # compile the changewrite binary into build/
lute test          # run the *.spec.luau test suite
```

`lute run install` copies the dependencies into `.lpm/<key>@<rev>` folders, and code requires them through the `lpm` alias in `.config.luau`, which `lute compile` bundles into the binary. It also fetches the shared [agent-skills](https://github.com/flipbook-labs/agent-skills) library that [`AGENTS.md`](AGENTS.md) routes agents to. That library is a dev dependency, so it lands in `.lpm/` but is not bundled into the binary.

## License

[MIT](LICENSE)
