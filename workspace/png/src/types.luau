export type Image = {
	width: number,
	height: number,
	-- Straight (not premultiplied) RGBA, one byte per channel, row by row.
	pixels: buffer,
}

return nil
