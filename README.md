# changewrite

Changewrite is a CLI tool and GitHub Action for release automation: it creates
release PRs, drafts and publishes GitHub releases, and exposes release state for
downstream jobs.

## Development

Changewrite uses [Rokit](https://github.com/rojo-rbx/rokit) for toolchain
management.

```sh
rokit install
lute run install   # install Loom dependencies and vendor them into packages/
lute run analyze   # run the stylua and luau-lsp checks
lute run build     # compile the changewrite binary into build/
lute test          # run the *.spec.luau test suite
```

`lute run install` fetches the Loom dependencies and vendors them into `packages/`
so they can be bundled into the compiled binary. It also fetches the shared
[agent-skills](https://github.com/flipbook-labs/agent-skills) library that
[`AGENTS.md`](AGENTS.md) routes agents to.

## License

[MIT](LICENSE)
