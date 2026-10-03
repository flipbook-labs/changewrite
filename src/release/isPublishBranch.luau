local getDebugBranch = require("@root/release/getDebugBranch")

-- A debug release run opens its publish PR from the debug branch, and that PR
-- consumes entries the same way the real one does.
local function isPublishBranch(branch: string, publishBranch: string): boolean
	return branch == publishBranch or branch == getDebugBranch(publishBranch)
end

return isPublishBranch
