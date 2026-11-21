-- Passes each line of Markdown outside fenced code blocks through `mapLine`,
-- and leaves lines inside them as they are, since a `#` there is code, such as
-- a shell comment. A fence inside a blockquote counts too, because highlights
-- render their bodies as quotes.
local function mapOutsideFences(text: string, mapLine: (line: string) -> string): string
	local lines: { string } = {}
	-- The open fence's character and length. Per CommonMark, only a line of at
	-- least as many of the same character, with nothing after it, closes it.
	local fenceCharacter: string? = nil
	local fenceLength = 0
	-- A fence opened inside a blockquote also closes when the quote ends,
	-- even without a closing fence, so the lines after it are outside again.
	local isFenceQuoted = false
	for line in (text .. "\n"):gmatch("(.-)\n") do
		local isQuoted = line:match("^>") ~= nil
		if fenceCharacter ~= nil and isFenceQuoted and not isQuoted then
			fenceCharacter = nil
		end

		local content = line:gsub("^>%s?", "")
		if fenceCharacter == nil then
			local marker = content:match("^ ? ? ?(```+)") or content:match("^ ? ? ?(~~~+)")
			if marker then
				fenceCharacter = marker:sub(1, 1)
				fenceLength = #marker
				isFenceQuoted = isQuoted
			else
				line = mapLine(line)
			end
		else
			local closing = content:match("^ ? ? ?([`~]+)%s*$")
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

return mapOutsideFences
