local readVersionConfig = require("@root/release/readVersionConfig")

local function getUnreleasedChangesDir(): string
	return readVersionConfig().unreleasedChangesDir
end

return getUnreleasedChangesDir
