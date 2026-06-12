local cli = require("@batteries/cli")

export type Command = {
	run: (args: { string }) -> (),
	title: string,
	summary: string,
	parser: cli.Parser?,
}

return nil
