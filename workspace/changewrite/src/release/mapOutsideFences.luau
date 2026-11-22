local function countIndent(text: string): number
	return #(text:match("^ *") :: string)
end

-- Passes each line of Markdown outside fenced code blocks through `mapLine`,
-- and leaves lines inside them as they are, since a `#` there is code, such as
-- a shell comment. A fence inside a blockquote or a list item counts too,
-- because highlights render their bodies as quotes and plain changelogs indent
-- an entry's body under its bullet.
local function mapOutsideFences(text: string, mapLine: (line: string) -> string): string
	local lines: { string } = {}
	-- The open fence's character and length. Per CommonMark, only a line of at
	-- least as many of the same character, with nothing after it, closes it.
	local fenceCharacter: string? = nil
	local fenceLength = 0
	-- A fence that opened inside a blockquote or a list item also closes when
	-- that block ends, even without a closing fence, so the lines after it are
	-- outside again. A blockquote ends at a line without `>`.
	local isFenceQuoted = false
	-- A list item ends at the first non-blank line indented less than the
	-- item's text. `listIndent` is that indent for the list item the current
	-- line is in, or 0 outside a list. `fenceIndent` is the same indent for the
	-- item the open fence is in.
	local fenceIndent = 0
	local listIndent = 0
	for line in (text .. "\n"):gmatch("(.-)\n") do
		local isQuoted = line:match("^>") ~= nil
		if fenceCharacter ~= nil and isFenceQuoted and not isQuoted then
			fenceCharacter = nil
		end

		-- A quote marker belongs to the Markdown only outside a fence or in a
		-- fence the quote opened. In a fence outside any quote, a line such as
		-- "> ```" is code, so it can't close the fence.
		local isMarkup = fenceCharacter == nil or isFenceQuoted
		local content = if isMarkup then line:gsub("^>%s?", "") else line
		local isBlank = content:match("^%s*$") ~= nil

		if fenceCharacter ~= nil and fenceIndent > 0 and not isBlank and countIndent(content) < fenceIndent then
			fenceCharacter = nil
		end

		if fenceCharacter == nil then
			-- The text of a list item starts after its marker, and the lines
			-- after it are indented to match. That indent is removed before
			-- looking for a fence marker, which may itself be indented up to
			-- three spaces.
			local bullet = content:match("^( *[-*+] +)") or content:match("^( *%d+[.)] +)")
			local itemText = content
			if bullet then
				listIndent = #bullet
				itemText = content:sub(#bullet + 1)
			elseif not isBlank and countIndent(content) < listIndent then
				listIndent = 0
			else
				itemText = content:sub(listIndent + 1)
			end

			local marker = itemText:match("^ ? ? ?(```+)") or itemText:match("^ ? ? ?(~~~+)")
			if marker then
				fenceCharacter = marker:sub(1, 1)
				fenceLength = #marker
				isFenceQuoted = isQuoted
				fenceIndent = listIndent
			else
				line = mapLine(line)
			end
		else
			local closing = content:sub(fenceIndent + 1):match("^ ? ? ?([`~]+)%s*$")
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
