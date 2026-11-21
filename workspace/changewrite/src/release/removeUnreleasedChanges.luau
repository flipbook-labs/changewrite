local fs = require("@std/fs")
local path = require("@std/path")

local function removeUnreleasedChanges(files: { path.Path }): ()
	for _, file in files do
		fs.remove(file)
	end
end

return removeUnreleasedChanges
