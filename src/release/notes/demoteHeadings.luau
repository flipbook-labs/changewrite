local mapOutsideFences = require("@root/release/mapOutsideFences")

-- Shifts level 1 and 2 headings in an entry body down to level 4, so they nest
-- under the release. A `## ` line at the start of a line would otherwise read
-- as the next release's heading, and `extractReleaseSection` would end the
-- notes there.
local function demoteHeadings(text: string): string
	return mapOutsideFences(text, function(line)
		local rest = line:match("^##? (.*)$")
		if rest then
			return `#### {rest}`
		end
		return line
	end)
end

return demoteHeadings
