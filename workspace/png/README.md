# PNG

PNG encodes RGBA images as PNG files in pure Luau, so a Lute script can write images without a native library. Changewrite draws its release-note chips with it.

## Install

Add this to the `dependencies` in `pkg.luau` and run `lute pkg install --vendor`:

```luau
png = {
	rev = "v0.13.0",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/changewrite",
	target = "workspace/png",
},
```

The package lands in `.lpm/png@<rev>`. Requiring it through `@lpm` needs an `lpm` alias in your `.config.luau` that points at `./.lpm`.

## Use

Pass the image's size and a buffer of straight RGBA pixels, one byte per channel, row by row:

```luau
local fs = require("@std/fs")
local png = require("@lpm/png@v0.13.0")

local width, height = 16, 16
local pixels = buffer.create(width * height * 4)
buffer.fill(pixels, 0, 255) -- opaque white

fs.writeStringToFile("white.png", png.encodePng({ width = width, height = height, pixels = pixels }))
```

## Limits

Lute has no compression library, so `encodePng` writes uncompressed deflate blocks and a file is about as large as its raw pixels. That suits small images such as icons.

## Contributing

See Changewrite's [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

MIT.
