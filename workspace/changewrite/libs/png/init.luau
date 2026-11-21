-- Encodes RGBA images as PNG files.
local encodePng = require("@self/encodePng")
local types = require("@self/types")

export type Image = types.Image

return {
	encodePng = encodePng,
}
