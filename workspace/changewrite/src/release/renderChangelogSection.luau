local constants = require("@root/release/constants")
local excerptItems = require("@root/release/excerptItems")
local renderBullet = require("@root/release/renderBullet")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- With `focus`, renders a changelog preview of those entry files instead of
-- the whole section: only the categories they're in, each cut down to the
-- entries around them, with an excerpt marker wherever something is left out.
local function renderChangelogSection(
	version: string,
	entries: { UnreleasedChange },
	configuredCategories: { string }?,
	focus: types.Focus?
): string
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
	if configuredCategories then
		categories = configuredCategories
	else
		table.sort(categories)
	end

	local blocks: { string } = {}
	local focusedBlocks: { boolean } = {}
	for _, category in categories do
		if byCategory[category] == nil then
			continue
		end

		local bullets: { string } = {}
		local focusedBullets: { boolean } = {}
		for _, entry in byCategory[category] do
			-- Without chips or other markup, this changelog is meant to read
			-- well as plain text too, so the body stays open under the bullet
			-- instead of collapsing in HTML.
			local text = entry.summary
			if entry.body then
				text ..= `\n\n{entry.body}`
			end
			table.insert(bullets, renderBullet(text))
			table.insert(focusedBullets, focus ~= nil and focus[tostring(entry.file)] == true)
		end

		local excerpt = if focus then excerptItems(bullets, focusedBullets, constants.EXCERPT_NEIGHBORS) else nil
		table.insert(blocks, `### {category}\n\n` .. table.concat(excerpt or bullets, "\n\n"))
		table.insert(focusedBlocks, excerpt ~= nil)
	end
	if focus then
		blocks = excerptItems(blocks, focusedBlocks, 0) or {}
	end

	local section = `## v{plain}`
	if #blocks > 0 then
		section ..= "\n\n" .. table.concat(blocks, "\n\n")
	end
	return section
end

return renderChangelogSection
