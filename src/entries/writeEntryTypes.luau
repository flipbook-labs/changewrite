local fs = require("@std/fs")
local path = require("@std/path")

local planEntryTypes = require("@root/entries/planEntryTypes")

-- Returns the file it wrote, or nil when the file was already current.
local function writeEntryTypes(): path.Path?
	local plan = planEntryTypes()
	if plan.isCurrent then
		return nil
	end
	local dir = path.dirname(plan.file)
	if not fs.exists(dir) then
		fs.createDirectory(dir, { makeParents = true })
	end
	fs.writeStringToFile(plan.file, plan.contents)
	return plan.file
end

return writeEntryTypes
