local readVersionConfig = require("@root/release/readVersionConfig")

local function getSourceFile(): string
	return readVersionConfig().source.file
end

return getSourceFile
