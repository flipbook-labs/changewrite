local mapOutsideFences = require("@root/release/mapOutsideFences")

-- Moves every heading up by `levels`, stopping at level 1. Headings inside a
-- blockquote move too.
local function promoteHeadings(text: string, levels: number): string
	return mapOutsideFences(text, function(line)
		local quote, hashes, rest = line:match("^(>?%s?)(#+)(%s.*)$")
		if hashes == nil or #hashes > 6 then
			return line
		end
		local level = math.max(1, #hashes - levels)
		return `{quote}{string.rep("#", level)}{rest}`
	end)
end

return promoteHeadings
