local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle

-- The flags' built-in styles. A `[flag.<name>]` table in changewrite.toml
-- overrides any of these fields.
local flagStyles: { [string]: ChipStyle } = {
	breaking = {
		group = "flag",
		name = "breaking",
		text = "Breaking",
		colorMode = {
			light = { color = "#c8264b" },
			dark = { color = "#ff6b88" },
		},
	},
	deprecated = {
		group = "flag",
		name = "deprecated",
		text = "Deprecated",
		colorMode = {
			light = { color = "#6b7380" },
			dark = { color = "#9aa3b0" },
		},
	},
	security = {
		group = "flag",
		name = "security",
		text = "Security",
		colorMode = {
			light = { color = "#d4540b" },
			dark = { color = "#ff8c46" },
		},
	},
}

return flagStyles
