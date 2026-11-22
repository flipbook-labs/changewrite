-- Encodes RGBA images as PNG files.
local encodePng = require("@self/src/encodePng")
local types = require("@self/src/types")

export type Image = types.Image

return {
	encodePng = encodePng,
}
