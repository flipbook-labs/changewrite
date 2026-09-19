local path = require("@std/path")

local readVersionConfig = require("@root/release/readVersionConfig")

local function getSourceFile(): path.Path
	return readVersionConfig().source.file
end

return getSourceFile
