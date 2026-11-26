local collectUnreleasedChanges = require("@root/release/collectUnreleasedChanges")
local types = require("@root/release/types")

type UnreleasedChange = types.UnreleasedChange

-- Reads the unreleased changes for commands that build a release from them.
-- When any entry is invalid, this raises one error that lists every invalid
-- entry and why, so they can all be fixed in one pass.
local function readUnreleasedChanges(): { UnreleasedChange }
	local result = collectUnreleasedChanges()
	if #result.problems > 0 then
		local lines = { "Some changelog entries are invalid:" }
		for _, problem in result.problems do
			table.insert(lines, `  • {problem.file}: {problem.problem}`)
		end
		error(table.concat(lines, "\n"), 0)
	end
	return result.changes
end

return readUnreleasedChanges
