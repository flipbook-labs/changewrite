return {
	categories = { "Features", "Fixes", "Changes", "Dependencies" },
	version = {
		current = "0.13.0",
		mirror = {
			{ file = "workspace/changewrite/pkg.luau", pattern = 'version%s*=%s*"([^"]+)"' },
			{ file = "workspace/png/pkg.luau", pattern = 'version%s*=%s*"([^"]+)"' },
			{ file = "workspace/semver/pkg.luau", pattern = 'version%s*=%s*"([^"]+)"' },
			{ file = "workspace/truetype/pkg.luau", pattern = 'version%s*=%s*"([^"]+)"' },
			{ file = "workspace/vector/pkg.luau", pattern = 'version%s*=%s*"([^"]+)"' },
		},
	},
	kind = {
		CLI = { text = "CLI", color = "#1f883d" },
		Chips = { text = "Chips", color = "#d6409f" },
		Docs = { text = "Docs", color = "#bf8700" },
		Notes = { text = "Notes", color = "#7c5cff" },
		Publishing = { text = "Publishing", color = "#2f81f7" },
		Tooling = { text = "Tooling", color = "#6e7781" },
	},
}
