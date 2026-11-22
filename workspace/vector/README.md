# Vector

Vector builds 2D paths, writes them as SVG path data, and rasterizes them onto an anti-aliased RGBA canvas, all in pure Luau. Changewrite draws its release-note chips with it, as SVG and as PNG through the [PNG](../png) package.

## Install

Add this to the `dependencies` in `pkg.luau` and run `lute pkg install --vendor`:

```luau
vector = {
	rev = "v0.14.1",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/changewrite",
	target = "workspace/vector",
},
```

The package lands in `.lpm/vector@<rev>`. Requiring it through `@lpm` needs an `lpm` alias in your `.config.luau` that points at `./.lpm`.

## Use

Build a path, write it as SVG, and paint it onto a canvas:

```luau
local vector = require("@lpm/vector@v0.14.1")

local pill = vector.pillPath(0, 0, 80, 24)
print(vector.pathToSvgData(pill)) --> M12 0L68 0C74.63 0 80 5.37 80 12...

local scale = 2
local canvas = vector.createCanvas(80 * scale, 24 * scale, scale)
local r, g, b = vector.parseHexColor("#5b5bd6")
canvas.fillPath(pill, { r = r, g = g, b = b, a = 1 })

local pixels = canvas.toRgba()
```

`createCanvas` takes the canvas size in pixels and a scale that multiplies every path coordinate, so the same path can be drawn at any density. Each `fillPath` paints over the last. `toRgba` returns straight RGBA, one byte per channel, row by row, which is what PNG's `encodePng` takes.

## Paths

A path is a list of `M`, `L`, `Q`, `C`, and `Z` commands in pixels, with y pointing down. Fills use the nonzero rule, so a contour drawn in the opposite direction cuts a hole: `pillPath` takes an optional `isCounterclockwise` for that.

## Contributing

See Changewrite's [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

MIT.
