# TrueType

TrueType reads static TrueType fonts and turns text into outline paths, so a Lute script can draw text without a font renderer. Changewrite draws the labels on its release-note chips with it.

## Install

Add this to the `dependencies` in `pkg.luau` and run `lute pkg install --vendor`:

```luau
truetype = {
	rev = "v0.15.0",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/changewrite",
	target = "workspace/truetype",
},
```

The package lands in `.lpm/truetype@<rev>`. Requiring it through `@lpm` needs an `lpm` alias in your `.config.luau` that points at `./.lpm`.

## Use

Read a font from its file, then measure text or lay it out as a path in pixels:

```luau
local fs = require("@std/fs")
local truetype = require("@lpm/truetype@v0.15.0")

local font = truetype.readTrueTypeFont(buffer.fromstring(fs.readFileToString("Font.ttf")))

local width = truetype.measureText(font, "Hello", 16, 0)
local path = truetype.layoutText(font, "Hello", 0, 16, 16, 0)
```

`measureText` takes the font, text, font size, and letter spacing. `layoutText` also takes where the text starts and its baseline, and returns one path of `M`, `L`, `Q`, and `Z` commands with y pointing down, the convention SVG uses.

## Limits

TrueType needs a font's `glyf` outlines, so CFF-based OpenType fonts don't load. It maps characters through the font's Windows Unicode BMP character map, so characters outside the Basic Multilingual Plane have no glyph.

## Contributing

See Changewrite's [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

MIT.
