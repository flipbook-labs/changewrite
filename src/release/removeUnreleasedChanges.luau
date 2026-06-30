local fs = require("@std/fs")

local function removeUnreleasedChanges(files: { string }): ()
	for _, file in files do
		fs.remove(file)
	end
end

return removeUnreleasedChanges
