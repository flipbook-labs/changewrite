# changewrite

Changewrite is a small release workflow tool for Flipbook Labs repositories. It provides:

- a Lute CLI for stepping through the release lifecycle
- a GitHub Action that orchestrates release PRs and GitHub releases
- a stable `changewrite.toml` version source that can optionally mirror into package manifests

## Version Configuration

Every repository using changewrite should commit a `changewrite.toml` file.

```toml
[version]
current = "0.1.0"
```

`changewrite.toml` is the default source of truth. If a repository already has a manifest that should own the version, point changewrite at it:

```toml
[version]
file = "wally.toml"
# pattern = 'version = "([^"]+)"'
```

When `pattern` is omitted, changewrite auto-detects common manifests:

- `changewrite.toml`
- `wally.toml`
- `rotriever.toml`
- `package.json`
- `loom.config.luau`

You can also keep `changewrite.toml` as the source of truth and mirror the bumped version into other files during `release prepare-pr`:

```toml
[version]
current = "0.1.0"
mirror = [
  { file = "loom.config.luau" },
  { file = "package.json" },
]
```

## CLI

```sh
changewrite release gate
changewrite release draft --version 1.2.0
changewrite release publish --tag v1.2.0
changewrite release attach --tag v1.2.0 --files changewrite-linux-x86_64.zip
changewrite release prepare-pr --bump minor
changewrite release notes --version 1.2.0
```

Command path overrides:

| Env var | Default |
| --- | --- |
| `CHANGEWRITE_GIT_CMD` | `git` |
| `CHANGEWRITE_GH_CMD` | `gh` |
| `CHANGEWRITE_GIT_CLIFF_CMD` | `git-cliff` |

## GitHub Action

The root action is the primary integration point:

```yaml
name: Release

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      force_publish:
        description: Tag and publish the configured version
        type: boolean
        default: false

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    outputs:
      should_publish: ${{ steps.changewrite.outputs.should_publish }}
      has_changes: ${{ steps.changewrite.outputs.has_changes }}
      version: ${{ steps.changewrite.outputs.version }}
      tag: ${{ steps.changewrite.outputs.tag }}
      release_created: ${{ steps.changewrite.outputs.release_created }}
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - id: changewrite
        uses: flipbook-labs/changewrite@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          app-id: ${{ secrets.CHANGEWRITE_APP_ID }}
          private-key: ${{ secrets.CHANGEWRITE_APP_PRIVATE_KEY }}
          force-publish: ${{ inputs.force_publish || false }}
```

The action:

1. builds the changewrite CLI from the action checkout
2. runs the CLI against the consuming repository checkout
3. drafts and optionally publishes the configured version when it has no tag
4. creates or updates a publish PR when there are unreleased commits

`app-id` and `private-key` are optional but recommended. A GitHub App token allows the generated branch push and release publish event to trigger downstream workflows. If omitted, changewrite falls back to `github-token`.

## Artifact Releases

Set `publish-immediately: "false"` when a repository needs to build and attach artifacts before publishing the GitHub release. Downstream jobs can use the action outputs to decide when to build.

```yaml
jobs:
  release:
    # same as above
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - id: changewrite
        uses: flipbook-labs/changewrite@v1
        with:
          publish-immediately: "false"
          app-id: ${{ secrets.CHANGEWRITE_APP_ID }}
          private-key: ${{ secrets.CHANGEWRITE_APP_PRIVATE_KEY }}

  build:
    needs: release
    if: needs.release.outputs.should_publish == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - run: ./scripts/build-artifact.sh
      - uses: actions/upload-artifact@v7
        with:
          name: release-assets
          path: dist/*.zip

  attach-and-publish:
    needs: [release, build]
    if: needs.release.outputs.should_publish == 'true'
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v8
        with:
          name: release-assets
          path: assets

      - uses: CompeyDev/setup-rokit@v0.2.1
        with:
          version: v1.2.0

      - run: rokit add --global flipbook-labs/changewrite@0.1.0

      - run: changewrite release attach --tag "${{ needs.release.outputs.tag }}" --files assets/*.zip
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - run: changewrite release publish --tag "${{ needs.release.outputs.tag }}"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Major Version Pointer Tags

GitHub Actions consumed as `@v1` often move a major-version tag after a stable release is published:

```yaml
move-major-tag:
  if: github.event_name == 'release' && !github.event.release.prerelease
  runs-on: ubuntu-latest
  permissions:
    contents: write
  steps:
    - uses: actions/checkout@v6
      with:
        fetch-depth: 0

    - name: Move major version pointer tag
      env:
        RELEASE_TAG: ${{ github.event.release.tag_name }}
      run: |
        set -euo pipefail
        tag="$RELEASE_TAG"
        if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          echo "Release tag '$tag' is not a vMAJOR.MINOR.PATCH tag; nothing to do."
          exit 0
        fi

        major="${tag%%.*}"
        sha="$(git rev-list -n 1 "$tag")"

        git config user.name "github-actions[bot]"
        git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
        git tag -f "$major" "$sha"
        git push --force origin "refs/tags/$major"
```
