local path = require("@std/path")

local readVersionConfig = require("@root/release/readVersionConfig")

local function getUnreleasedChangesDir(): path.Path
	return readVersionConfig().unreleasedChangesDir
end

return getUnreleasedChangesDir
