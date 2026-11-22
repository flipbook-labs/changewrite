local path = require("@std/path")

local constants = require("@root/release/constants")
local types = require("@root/release/types")

type VersionTarget = types.VersionTarget

-- A target without its own pattern gets the default for its file name, so a
-- manifest in a subfolder, such as `workspace/png/pkg.luau`, reads the same
-- way as one at the root.
local function getVersionPattern(target: VersionTarget): string
	local pattern = target.pattern or constants.DEFAULT_PATTERNS[path.basename(target.file) or ""]
	assert(pattern, `No version pattern configured for {target.file}`)
	return pattern
end

return getVersionPattern
