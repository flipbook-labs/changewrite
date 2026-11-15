local fs = require("@std/fs")
local path = require("@std/path")

local chipConstants = require("@root/chips/constants")
local chipLock = require("@root/chips/chipLock")
local getAssetsDir = require("@root/chips/getAssetsDir")

-- The repo's chip lockfile, or nil when `changewrite generate` hasn't run.
local function readChipLock(): chipLock.ChipLock?
	local lockPath = path.join(getAssetsDir(), chipConstants.LOCKFILE_NAME)
	if not fs.exists(lockPath) then
		return nil
	end
	local success, result = pcall(chipLock.parse, fs.readFileToString(lockPath))
	assert(success, `{lockPath}: {result}`)
	return result
end

return readChipLock
