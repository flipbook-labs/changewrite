local function prependSection(changelog: string, section: string): string
	local header = changelog
	local releases = ""

	if changelog:sub(1, 3) == "## " then
		header = ""
		releases = changelog
	else
		local headingStart = changelog:find("\n## ")
		if headingStart then
			header = changelog:sub(1, headingStart - 1)
			releases = changelog:sub(headingStart + 1)
		end
	end

	header = header:gsub("%s+$", "")
	releases = releases:gsub("^%s+", ""):gsub("%s+$", "")

	local parts: { string } = {}
	if header ~= "" then
		table.insert(parts, header)
	end
	table.insert(parts, section)
	if releases ~= "" then
		table.insert(parts, releases)
	end
	return table.concat(parts, "\n\n\n") .. "\n"
end

return prependSection
