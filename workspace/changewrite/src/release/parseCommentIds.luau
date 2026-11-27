local splitLines = require("@root/release/splitLines")

-- The comment ids gh prints one per line, in the order it printed them.
local function parseCommentIds(output: string): { number }
	local ids: { number } = {}
	for _, line in splitLines(output) do
		-- With no matching comments, gh prints nothing, which splits into one
		-- empty line.
		if line ~= "" then
			local id = tonumber(line)
			assert(id, `gh listed a comment id that isn't a number: {line}`)
			table.insert(ids, id)
		end
	end
	return ids
end

return parseCommentIds
