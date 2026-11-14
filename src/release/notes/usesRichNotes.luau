local types = require("@root/release/types")

type ReleaseSummary = types.ReleaseSummary
type UnreleasedChange = types.UnreleasedChange

-- Rich notes are opt-in. A repository that uses none of their entry fields,
-- release summary, or config renders exactly the notes it always has.
local function usesRichNotes(entries: { UnreleasedChange }, summary: ReleaseSummary?, collapsed: { string }): boolean
	if summary ~= nil or #collapsed > 0 then
		return true
	end
	for _, entry in entries do
		if entry.kind ~= nil or #entry.flags > 0 or entry.highlight ~= nil or entry.pr ~= nil then
			return true
		end
	end
	return false
end

return usesRichNotes
