local function getDebugBranch(publishBranch: string): string
	return `debug-{publishBranch}`
end

return getDebugBranch
