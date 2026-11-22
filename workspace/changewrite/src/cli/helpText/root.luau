export type CommandSummary = {
	name: string,
	description: string,
}

export type RootConfig = {
	title: string,
	summary: string,
	commands: { CommandSummary },
	footer: string?,
}

local function buildRoot(config: RootConfig): string
	local lines: { string } = {
		config.title,
		config.summary,
		"",
		"USAGE:",
		`  {config.title} <command> [options]`,
		"",
		"COMMANDS:",
	}

	for _, command in config.commands do
		local padding = math.max(1, 10 - #command.name)
		table.insert(lines, `  {command.name}{string.rep(" ", padding)}{command.description}`)
	end

	table.insert(lines, "")
	table.insert(lines, config.footer or `For more information: {config.title} <command> --help`)

	return table.concat(lines, "\n")
end

local function printRoot(config: RootConfig): ()
	print(buildRoot(config))
end

return {
	buildRoot = buildRoot,
	printRoot = printRoot,
}
