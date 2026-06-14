local FLAG_COLUMN_WIDTH = 26

local function formatFlagPart(name: string, kind: string, aliases: { string }?): string
	if kind == "option" then
		return `--{name} <{name}>`
	end

	local aliasPart = ""
	if aliases and #aliases > 0 then
		aliasPart = `, -{table.concat(aliases :: { string }, ", -")}`
	end
	return `--{name}{aliasPart}`
end

local function formatHelpSuffix(help: string?, default: string?): string
	local parts: { string } = {}
	if help and help ~= "" then
		table.insert(parts, help)
	end
	if default then
		table.insert(parts, `(default: {default})`)
	end
	return table.concat(parts, " ")
end

local function formatArgLine(
	name: string,
	kind: string,
	options: {
		help: string?,
		aliases: { string }?,
		default: string?,
	}
): string
	local flagPart = formatFlagPart(name, kind, options.aliases)
	local padding = math.max(1, FLAG_COLUMN_WIDTH - #flagPart)
	local helpPart = formatHelpSuffix(options.help, options.default)
	return `  {flagPart}{string.rep(" ", padding)}{helpPart}`
end

local function formatPositionalLine(
	name: string,
	options: {
		help: string?,
		default: string?,
	}
): string
	local namePart = `<{name}>`
	local padding = math.max(1, FLAG_COLUMN_WIDTH - #namePart)
	local helpPart = formatHelpSuffix(options.help, options.default)
	return `  {namePart}{string.rep(" ", padding)}{helpPart}`
end

local function appendSection(lines: { string }, heading: string, bodyLines: { string })
	table.insert(lines, heading .. ":")
	for _, line in bodyLines do
		table.insert(lines, line)
	end
	table.insert(lines, "")
end

return {
	FLAG_COLUMN_WIDTH = FLAG_COLUMN_WIDTH,
	formatArgLine = formatArgLine,
	formatPositionalLine = formatPositionalLine,
	appendSection = appendSection,
}
