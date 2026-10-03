-- A debug release run opens its publish PR from `debug-<branch>`, and that PR
-- consumes entries the same way the real one does.
local function isPublishBranch(branch: string, publishBranch: string): boolean
	return branch == publishBranch or branch == `debug-{publishBranch}`
end

return isPublishBranch
