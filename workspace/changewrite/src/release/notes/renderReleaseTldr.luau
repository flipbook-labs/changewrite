local types = require("@root/release/types")

type ReleaseSummary = types.ReleaseSummary
type UnreleasedChange = types.UnreleasedChange

-- Without a hand-written summary, the highlight titles stand in, so a release
-- with headline changes still opens with what they are.
local function renderReleaseTldr(summary: ReleaseSummary?, entries: { UnreleasedChange }): string?
	if summary then
		return summary.tldr
	end

	local titles: { string } = {}
	for _, entry in entries do
		if entry.highlight then
			table.insert(titles, entry.highlight)
		end
	end

	if #titles == 0 then
		return nil
	elseif #titles == 1 then
		return `Highlights: {titles[1]}.`
	elseif #titles == 2 then
		return `Highlights: {titles[1]} and {titles[2]}.`
	end
	local last = table.remove(titles) :: string
	return `Highlights: {table.concat(titles, ", ")}, and {last}.`
end

return renderReleaseTldr
