# Changewrite

Changewrite turns changelog entries into GitHub releases. Each pull request adds a short entry, and Changewrite keeps a publish PR open that bumps the version and assembles the changelog. Merging that PR tags the release, drafts its notes, and publishes it.

It runs as a GitHub Action, with a CLI for checking entries and previewing notes locally.

## Install

As a GitHub Action:

```yaml
- uses: flipbook-labs/changewrite@v0.13.0
```

With Rokit, for the CLI:

```sh
rokit add flipbook-labs/changewrite
```

## Use

1. Run `changewrite init` at the repository root. It creates `changewrite.toml` and mirrors the version into the manifests it finds, such as `wally.toml` and `pkg.luau`.
2. Add a workflow that runs the Action on every push to `main`:

   ```yaml
   on:
     push:
       branches: [main]

   jobs:
     release:
       runs-on: ubuntu-latest
       permissions:
         contents: write
         pull-requests: write
       steps:
         - uses: actions/checkout@v7
           with:
             fetch-depth: 0
         - uses: flipbook-labs/changewrite@v0.13.0
   ```

3. Have each pull request add an entry under `.changes/`.

Run `changewrite help` for every command, and see [`action.yml`](action.yml) for every Action input and output.

## Entries

An entry is a Luau file in `.changes/` that returns a version bump, a category, and a one-line summary for the changelog:

```luau
return {
	bump = "patch",
	category = "Fixes",
	summary = "One short sentence describing the change, written for the changelog.",
}
```

[`.changes/README.md`](.changes/README.md) covers every field, including a longer `body`. Markdown entries from older versions fail `changewrite check`, and `changewrite check --fix` converts them.

Run `changewrite check` to validate a branch's entries. To fail pull requests that don't add one, run the Action again in a separate workflow triggered by `pull_request`, with `fetch-depth: 0` on checkout and `require-entry: true`. That input runs only the entry check and skips releases, so keep it out of the release workflow.

## Configure

`changewrite.toml` holds the current version, the files it's mirrored into, and the categories and kinds entries can use. The publish PR's title and body, and hooks that run after the release is drafted or published, are Action inputs.

By default the publish PR is opened with `GITHUB_TOKEN`, so it won't trigger other workflows. Pass a GitHub App token or PAT as `pr-token` if it should.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.

The bundled Schibsted Grotesk font is licensed under the [SIL Open Font License](workspace/changewrite/src/chips/font/OFL.txt).
