-- Shifts level 1 and 2 headings in an entry body down to level 4, so they nest
-- under the release. A `## ` line at the start of a line would otherwise read
-- as the next release's heading, and `extractReleaseSection` would end the
-- notes there. Lines inside fenced code blocks are left alone, since a `#`
-- there is code, such as a shell comment.
local function demoteHeadings(text: string): string
	local lines: { string } = {}
	local fence: string? = nil
	for line in (text .. "\n"):gmatch("(.-)\n") do
		local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
		if marker then
			if fence == nil then
				fence = marker:sub(1, 1)
			elseif marker:sub(1, 1) == fence then
				fence = nil
			end
			table.insert(lines, line)
			continue
		end

		if fence == nil then
			local rest = line:match("^##? (.*)$")
			if rest then
				line = `#### {rest}`
			end
		end
		table.insert(lines, line)
	end
	return table.concat(lines, "\n")
end

return demoteHeadings
