local renderBullet = require("@root/release/renderBullet")

local function renderNumberedList(items: { string }): string
	local lines: { string } = {}
	for index, item in items do
		table.insert(lines, renderBullet(item, `{index}.`))
	end
	return table.concat(lines, "\n")
end

return renderNumberedList
