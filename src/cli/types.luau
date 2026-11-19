local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")

export type Command = {
	run: (args: { string }) -> (),
	title: string,
	summary: string,
	parser: cli.Parser?,
}

return nil
