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

return renderBullet
