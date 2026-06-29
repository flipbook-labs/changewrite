local changePartials = require("@root/release/changePartials")

type Partial = changePartials.Partial

-- Render a markdown bullet for one entry, indenting any continuation lines so a
-- multi-paragraph body stays within the list item.
local function renderBullet(body: string): string
	local out = {}
	local first = true
	for line in (body .. "\n"):gmatch("(.-)\n") do
		if first then
			table.insert(out, `- {line}`)
			first = false
		elseif line == "" then
			table.insert(out, "")
		else
			table.insert(out, `  {line}`)
		end
	end
	return table.concat(out, "\n")
end

-- Render the changelog section for a release: a `## v{version}` heading followed
-- by the entries grouped under `### {category}` headings. Categories are sorted
-- alphabetically for deterministic output; entries keep the order they were read
-- in. Pure — the caller handles reading/writing CHANGELOG.md.
local function renderChangelogSection(version: string, partials: { Partial }): string
	local plain = (version:gsub("^v", ""))

	local byCategory: { [string]: { Partial } } = {}
	local categories: { string } = {}
	for _, partial in partials do
		if byCategory[partial.category] == nil then
			byCategory[partial.category] = {}
			table.insert(categories, partial.category)
		end
		table.insert(byCategory[partial.category], partial)
	end
	table.sort(categories)

	local blocks: { string } = {}
	for _, category in categories do
		local bullets: { string } = {}
		for _, partial in byCategory[category] do
			table.insert(bullets, renderBullet(partial.body))
		end
		table.insert(blocks, `### {category}\n\n` .. table.concat(bullets, "\n\n"))
	end

	local section = `## v{plain}`
	if #blocks > 0 then
		section ..= "\n\n" .. table.concat(blocks, "\n\n")
	end
	return section
end

return renderChangelogSection
