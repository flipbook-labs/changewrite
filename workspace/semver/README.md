# Semver

Semver parses and steps `major.minor.patch` versions. It's the version logic Changewrite releases with, published as a package of its own with no dependencies.

## Install

Add this to the `dependencies` in `pkg.luau` and run `lute pkg install --vendor`:

```luau
semver = {
	rev = "v0.17.0",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/changewrite",
	target = "workspace/semver",
},
```

The package lands in `.lpm/semver@<rev>`. Requiring it through `@lpm` needs an `lpm` alias in your `.config.luau` that points at `./.lpm`.

## Use

```luau
local semver = require("@lpm/semver@v0.17.0")

print(semver.getNextVersion("1.4.2", "minor")) --> 1.5.0
print(semver.pickHighestVersion({ "1.2.0", "1.10.0", "1.9.3" })) --> 1.10.0
```

`parseVersion` splits a version into its three numbers, and `parseVersionComponent` checks that a string is `major`, `minor`, or `patch`, erroring otherwise. `semver.VersionComponent` names those three values, as in `semver.VersionComponent.Minor`. Versions are plain `x.y.z`, with no `v` prefix, pre-release tag, or build metadata.

## Contributing

See Changewrite's [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

MIT.
