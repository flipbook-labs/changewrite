local fs = require("@std/fs")
local path = require("@std/path")

local findStaleChips = require("@root/chips/findStaleChips")
local getAssetsDir = require("@root/chips/getAssetsDir")
local planChips = require("@root/chips/planChips")
local readChipLock = require("@root/chips/readChipLock")
local readChipStyles = require("@root/chips/readChipStyles")

-- The repo's chips that don't match changewrite.toml, for `generate --check`
-- and `check`.
local function findStaleChipAssets(): { string }
	local dir = getAssetsDir()
	return findStaleChips(planChips(readChipStyles()), readChipLock(), function(name: string): boolean
		return fs.exists(path.join(dir, name))
	end)
end

return findStaleChipAssets
