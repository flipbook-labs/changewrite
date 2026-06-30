local fs = require("@std/fs")

local function removeChangePartials(files: { string }): ()
	for _, file in files do
		fs.remove(file)
	end
end

return removeChangePartials
