local deriveDarkColor = require("@root/chips/deriveDarkColor")
local types = require("@root/chips/types")

type ChipStyle = types.ChipStyle

-- The flags' built-in styles. A `flag.<name>` table in changewrite.luau
-- overrides any of these fields. Most dark colors come from deriveDarkColor.
-- Security keeps its hand-picked one, because the derived color is 0.027 from
-- it in OKLab, past the roughly 0.02 where a difference becomes noticeable.
local flagStyles: { [string]: ChipStyle } = {
	Breaking = {
		group = "flag",
		name = "Breaking",
		text = "Breaking",
		colorMode = {
			light = { color = "#c8264b" },
			dark = { color = deriveDarkColor("#c8264b") },
		},
	},
	Deprecated = {
		group = "flag",
		name = "Deprecated",
		text = "Deprecated",
		colorMode = {
			light = { color = "#6b7380" },
			dark = { color = deriveDarkColor("#6b7380") },
		},
	},
	Security = {
		group = "flag",
		name = "Security",
		text = "Security",
		colorMode = {
			light = { color = "#d4540b" },
			dark = { color = "#ff8c46" },
		},
	},
}

return flagStyles
