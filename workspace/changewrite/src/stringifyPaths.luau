local path = require("@std/path")

local function stringifyPaths(paths: { path.Path }): { string }
	local strings = {}
	for _, filePath in paths do
		table.insert(strings, tostring(filePath))
	end
	return strings
end

return stringifyPaths
