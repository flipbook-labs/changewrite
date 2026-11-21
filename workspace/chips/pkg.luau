return {
	package = {
		name = "chips",
		version = "0.13.0",
		dependencies = {
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			png = { sourceKind = "path", source = "../png" },
			truetype = { sourceKind = "path", source = "../truetype" },
			vector = { sourceKind = "path", source = "../vector" },
		},
	},
}
