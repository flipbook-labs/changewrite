local types = require("@root/chips/types")

type ChipMetrics = types.ChipMetrics

-- How every chip is drawn. Each chip's hash covers these values, so changing
-- one gives every chip new files.
return table.freeze({
	-- Bump when a change to the drawing code alters what chips look like, so
	-- their hashes change too and GitHub fetches the new images.
	styleVersion = 1,
	-- The PNG fallback is drawn at this multiple of the chip's size, so it stays
	-- sharp on high-density screens at the chip's height.
	pngScale = 2,
	metrics = table.freeze<<ChipMetrics>>({
		height = 18,
		rimWidth = 1,
		paddingLeft = 6,
		dotDiameter = 6,
		dotGap = 5,
		paddingRight = 7,
		fontSize = 11,
		letterSpacing = 0,
	}),
})
