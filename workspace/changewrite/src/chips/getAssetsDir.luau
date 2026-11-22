local path = require("@std/path")

local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")

-- Generated assets live in a folder inside the unreleased-changes directory.
-- Only Markdown files directly in that directory are entries, so nothing here
-- is ever read or consumed as one.
local function getAssetsDir(): path.Path
	return path.join(getUnreleasedChangesDir(), "assets")
end

return getAssetsDir
