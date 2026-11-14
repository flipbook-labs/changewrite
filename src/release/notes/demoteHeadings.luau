-- Shifts level 1 and 2 headings in an entry body down to level 4, so they nest
-- under the release. A `## ` line at the start of a line would otherwise read
-- as the next release's heading, and `extractReleaseSection` would end the
-- notes there. Lines inside fenced code blocks are left alone, since a `#`
-- there is code, such as a shell comment.
local function demoteHeadings(text: string): string
	local lines: { string } = {}
	-- The open fence's character and length. Per CommonMark, only a line of at
	-- least as many of the same character, with nothing after it, closes it.
	local fenceCharacter: string? = nil
	local fenceLength = 0
	for line in (text .. "\n"):gmatch("(.-)\n") do
		if fenceCharacter == nil then
			local marker = line:match("^ ? ? ?(```+)") or line:match("^ ? ? ?(~~~+)")
			if marker then
				fenceCharacter = marker:sub(1, 1)
				fenceLength = #marker
			else
				local rest = line:match("^##? (.*)$")
				if rest then
					line = `#### {rest}`
				end
			end
		else
			local closing = line:match("^ ? ? ?([`~]+)%s*$")
			if closing and closing:sub(1, 1) == fenceCharacter and #closing >= fenceLength then
				local isUniform = closing == string.rep(fenceCharacter, #closing)
				if isUniform then
					fenceCharacter = nil
				end
			end
		end
		table.insert(lines, line)
	end
	return table.concat(lines, "\n")
end

return demoteHeadings
