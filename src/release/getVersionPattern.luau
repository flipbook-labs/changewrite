local constants = require("@root/release/constants")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

local function getVersionPattern(target: VersionTarget): string
	local pattern = target.pattern or constants.DEFAULT_PATTERNS[target.file]
	assert(pattern, `No version pattern configured for {target.file}`)
	return pattern
end

return getVersionPattern
