--[[
	A summary is one line in a long list of changes. Past a short sentence it
	reads as a paragraph a skimming reader skips, and a line break would split
	its list item. Returns a message for each way the summary falls short, or an
	empty list when it's fine.
]]
local function findSummaryProblems(summary: string, maxLength: number): { string }
	local problems: { string } = {}
	if summary:find("\n", 1, true) then
		table.insert(problems, "Keep the summary on one line. Put any details in `body`.")
	end

	-- `utf8.len` returns nil for invalid UTF-8, which falls back to bytes.
	local length = utf8.len(summary) or #summary
	if length > maxLength then
		table.insert(
			problems,
			`The summary is {length} characters, over the limit of {maxLength}. Keep it to one short sentence and put any details in \`body\`.`
		)
	end
	return problems
end

return findSummaryProblems
