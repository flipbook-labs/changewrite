-- The data the chip generator draws from. Run `lute run chips` after changing
-- it, and bump `version` when restyling chips that are already published,
-- because GitHub's image proxy keeps serving the old files at the old URLs.
local types = require("@root/chips/types")

type ChipMetrics = types.ChipMetrics
type ChipSpec = types.ChipSpec

local metrics: ChipMetrics = {
	height = 18,
	rimWidth = 1,
	paddingLeft = 6,
	dotDiameter = 6,
	dotGap = 5,
	paddingRight = 7,
	fontSize = 10,
	letterSpacing = 0.7,
}

local function solid(color: string): types.Paint
	return {
		color = color,
		opacity = 1,
	}
end

local function tinted(color: string, opacity: number): types.Paint
	return {
		color = color,
		opacity = opacity,
	}
end

local chips: { ChipSpec } = {
	{
		name = "new",
		label = "NEW",
		light = {
			tint = solid("#dcf7f2"),
			rim = solid("#9fe5d9"),
			dot = solid("#0b7f73"),
			text = solid("#08665c"),
		},
		dark = {
			tint = tinted("#18d6c0", 0.14),
			rim = tinted("#18d6c0", 0.4),
			dot = solid("#18d6c0"),
			text = solid("#4fe8d6"),
		},
	},
	{
		name = "improved",
		label = "IMPROVED",
		light = {
			tint = solid("#e4e9ff"),
			rim = solid("#b6c3ff"),
			dot = solid("#3b56d6"),
			text = solid("#3048b8"),
		},
		dark = {
			tint = tinted("#7d96ff", 0.15),
			rim = tinted("#7d96ff", 0.42),
			dot = solid("#7d96ff"),
			text = solid("#a3b4ff"),
		},
	},
	{
		name = "fixed",
		label = "FIXED",
		light = {
			tint = solid("#f2e6ff"),
			rim = solid("#d8b8ff"),
			dot = solid("#7f35d6"),
			text = solid("#6c27bd"),
		},
		dark = {
			tint = tinted("#bf73ff", 0.15),
			rim = tinted("#bf73ff", 0.42),
			dot = solid("#bf73ff"),
			text = solid("#d3a0ff"),
		},
	},
	{
		name = "breaking",
		label = "BREAKING",
		light = {
			tint = solid("#ffe5eb"),
			rim = solid("#ffb3c3"),
			dot = solid("#c8264b"),
			text = solid("#b01e40"),
		},
		dark = {
			tint = tinted("#ff6b88", 0.15),
			rim = tinted("#ff6b88", 0.42),
			dot = solid("#ff6b88"),
			text = solid("#ff95aa"),
		},
	},
	{
		name = "api",
		label = "API",
		light = {
			tint = solid("#fff1d6"),
			rim = solid("#f5cf85"),
			dot = solid("#a86a00"),
			text = solid("#8a5600"),
		},
		dark = {
			tint = tinted("#ffbe50", 0.14),
			rim = tinted("#ffbe50", 0.4),
			dot = solid("#ffbe50"),
			text = solid("#ffd48a"),
		},
	},
	{
		name = "deprecated",
		label = "DEPRECATED",
		light = {
			tint = solid("#eef0f3"),
			rim = solid("#cdd2da"),
			dot = solid("#6b7380"),
			text = solid("#4f5663"),
		},
		dark = {
			tint = tinted("#9aa3b0", 0.14),
			rim = tinted("#9aa3b0", 0.4),
			dot = solid("#9aa3b0"),
			text = solid("#c3c9d2"),
		},
	},
	{
		name = "security",
		label = "SECURITY",
		light = {
			tint = solid("#ffeadb"),
			rim = solid("#ffc29e"),
			dot = solid("#d4540b"),
			text = solid("#b04306"),
		},
		dark = {
			tint = tinted("#ff8c46", 0.15),
			rim = tinted("#ff8c46", 0.42),
			dot = solid("#ff8c46"),
			text = solid("#ffb084"),
		},
	},
}

return {
	version = "v1",
	font = "assets/chips/font/SchibstedGrotesk-Bold.ttf",
	-- The PNG fallback is drawn at this multiple of the chip's size, so it stays
	-- sharp on high-density screens when shown at 18px tall.
	pngScale = 2,
	metrics = metrics,
	chips = chips,
}
