local renderBullet = require("@root/release/renderBullet")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

local function renderChangelogSection(version: string, entries: { UnreleasedChange }): string
	local plain = version:gsub("^v", "")

	local byCategory: { [string]: { UnreleasedChange } } = {}
	local categories: { string } = {}
	for _, entry in entries do
		if byCategory[entry.category] == nil then
			byCategory[entry.category] = {}
			table.insert(categories, entry.category)
		end
		table.insert(byCategory[entry.category], entry)
	end
	table.sort(categories)

	local blocks: { string } = {}
	for _, category in categories do
		local bullets: { string } = {}
		for _, entry in byCategory[category] do
			table.insert(bullets, renderBullet(entry.body))
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
