return {
	package = {
		name = "changewrite",
		version = "0.14.1",
		dependencies = {
			png = { sourceKind = "path", source = "../png" },
			semver = { sourceKind = "path", source = "../semver" },
			truetype = { sourceKind = "path", source = "../truetype" },
			vector = { sourceKind = "path", source = "../vector" },
			["flipbook-batteries"] = {
				rev = "v0.13.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
		},
	},
}
