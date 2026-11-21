# changewrite

Changewrite is a CLI tool and GitHub Action for release automation: it creates release PRs, drafts and publishes GitHub releases, and exposes release state for downstream jobs.

## Changelog entries

Each change is a Luau file in `.changes/` that returns its fields, and Changewrite assembles them into `CHANGELOG.md` and the release notes. [`.changes/README.md`](.changes/README.md) describes the format and the checks `changewrite check` runs over every entry.

## Configuration

A repo configures Changewrite with a `changewrite.luau` at its root that returns the settings as a table. `changewrite init` writes a starter one:

```luau
return {
	categories = { "Features", "Fixes", "Changes", "Dependencies" },
	version = {
		current = "0.1.0",
		mirror = {
			{ file = "pkg.luau" },
		},
	},
}
```

Like a changelog entry, the file runs with only the `string`, `table`, `math`, and `utf8` libraries and a few basic functions such as `tostring` and `typeof`, because `changewrite check` runs it on pull requests, including ones from forks. A value can come from a local, such as a color several kinds share, but the file can't `require` other modules.

Changewrite bumps the version by rewriting the `current = "x.y.z"` line, so keep `version.current` a string literal. To keep the version in another file instead, such as `wally.toml`, set `version.file` and, for a file Changewrite doesn't know, `version.pattern`.

Changewrite used to read `changewrite.toml`. It now fails while that file is present, and `changewrite check --fix` converts it to `changewrite.luau`, renaming `unreleased_changes` and `max_summary_length` to `unreleasedChanges` and `maxSummaryLength`. Comments in the TOML file aren't carried over.

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
