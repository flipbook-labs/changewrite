local cli = require("@batteries/cli")

local format = require("@self/format")
local root = require("@self/root")

local PROGRAM_NAME = "changewrite"

export type HelpConfig = {
	title: string,
	summary: string?,
}

type ArgData = {
	name: string,
	kind: string,
	options: {
		help: string?,
		aliases: { string }?,
		default: string?,
		required: boolean?,
		hidden: boolean?,
	},
}

local function collectArgLines(parser: cli.Parser): ({ string }, { string })
	local requiredLines: { string } = {}
	local optionLines: { string } = {}

	for _, argument in parser.arguments :: { ArgData } do
		if argument.options.hidden then
			continue
		end
		if argument.kind == "positional" or argument.kind == "variadic" then
			continue
		end

		local line = format.formatArgLine(argument.name, argument.kind, argument.options)
		if argument.options.required then
			table.insert(requiredLines, line)
		else
			table.insert(optionLines, line)
		end
	end

	return requiredLines, optionLines
end

local function build(parser: cli.Parser, config: HelpConfig): string
	local title = `{PROGRAM_NAME} {config.title}`
	local lines: { string } = { title }

	if config.summary then
		table.insert(lines, config.summary)
	end

	table.insert(lines, "")
	table.insert(lines, "USAGE:")
	table.insert(lines, `  {parser:usage(title)}`)
	table.insert(lines, "")

	local requiredLines, optionLines = collectArgLines(parser)

	if #requiredLines > 0 then
		format.appendSection(lines, "REQUIRED", requiredLines)
	end

	if #optionLines > 0 then
		format.appendSection(lines, "OPTIONS", optionLines)
	end

	-- Trim trailing blank line from last appendSection
	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	return table.concat(lines, "\n")
end

local function printHelp(parser: cli.Parser, config: HelpConfig): ()
	print(build(parser, config))
end

return {
	build = build,
	print = printHelp,
	buildRoot = root.buildRoot,
	printRoot = root.printRoot,
}
