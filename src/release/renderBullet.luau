-- Continuation lines are indented to line up with the text after the marker,
-- which is what Markdown needs to keep them inside the list item.
local function renderBullet(body: string, marker: string?): string
	local prefix = `{marker or "-"} `
	local indent = string.rep(" ", #prefix)
	local out = {}
	local first = true
	for line in (body .. "\n"):gmatch("(.-)\n") do
		if first then
			table.insert(out, prefix .. line)
			first = false
		elseif line == "" then
			table.insert(out, "")
		else
			table.insert(out, indent .. line)
		end
	end
	return table.concat(out, "\n")
end

return renderBullet
