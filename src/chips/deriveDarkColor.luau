local parseHexColor = require("@libs/vector/parseHexColor")

-- How much lighter, in OKLCH lightness from 0 to 1, a chip's dark color is
-- than its light one.
local LIGHTNESS_STEP = 0.16

local function cbrt(x: number): number
	return if x < 0 then -((-x) ^ (1 / 3)) else x ^ (1 / 3)
end

local function toLinear(channel: number): number
	return if channel <= 0.04045 then channel / 12.92 else ((channel + 0.055) / 1.055) ^ 2.4
end

local function fromLinear(channel: number): number
	return if channel <= 0.0031308 then channel * 12.92 else 1.055 * channel ^ (1 / 2.4) - 0.055
end

-- OKLab is a color space where equal steps look equally different, which is
-- what makes "the same color, only lighter" well defined. These conversions
-- follow Björn Ottosson's reference matrices.
local function toOklab(r: number, g: number, b: number): (number, number, number)
	r, g, b = toLinear(r), toLinear(g), toLinear(b)
	local l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
	local m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
	local s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
	return 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
		1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
		0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
end

-- Returns linear sRGB channels, which fall outside 0 to 1 when the color is
-- outside the sRGB gamut.
local function fromOklab(lightness: number, a: number, b: number): (number, number, number)
	local l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ^ 3
	local m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ^ 3
	local s = (lightness - 0.0894841775 * a - 1.2914855480 * b) ^ 3
	return 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
		-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
		-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
end

local function inGamut(r: number, g: number, b: number): boolean
	local epsilon = 1e-6
	return r >= -epsilon
		and r <= 1 + epsilon
		and g >= -epsilon
		and g <= 1 + epsilon
		and b >= -epsilon
		and b <= 1 + epsilon
end

local function toHex(channel: number): string
	return string.format("%02x", math.round(math.clamp(fromLinear(channel), 0, 1) * 255))
end

-- A color picked to read on a white page is usually too dark on GitHub's dark
-- background. This returns the dark color mode's version of a chip's color:
-- the same hue and chroma, LIGHTNESS_STEP lighter in OKLCH, up to white. When
-- that lighter color is more saturated than sRGB can show, its chroma is
-- reduced until it fits. Scaling OKLab's a and b together does that while
-- keeping the hue.
local function deriveDarkColor(color: string): string
	local lightness, a, b = toOklab(parseHexColor(color))
	lightness = math.min(lightness + LIGHTNESS_STEP, 1)

	-- Binary search for the largest share of the chroma that stays in gamut.
	local low, high = 0, 1
	if not inGamut(fromOklab(lightness, a, b)) then
		for _ = 1, 24 do
			local mid = (low + high) / 2
			if inGamut(fromOklab(lightness, a * mid, b * mid)) then
				low = mid
			else
				high = mid
			end
		end
		a, b = a * low, b * low
	end

	local r, g, blue = fromOklab(lightness, a, b)
	return `#{toHex(r)}{toHex(g)}{toHex(blue)}`
end

return deriveDarkColor
