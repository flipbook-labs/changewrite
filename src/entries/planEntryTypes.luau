local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local readCategories = require("@root/release/readCategories")
local readKindNames = require("@root/release/readKindNames")
local renderEntryTypes = require("@root/entries/renderEntryTypes")

export type EntryTypesPlan = {
	file: path.Path,
	contents: string,
	isCurrent: boolean,
}

local function planEntryTypes(): EntryTypesPlan
	local file = path.join(getUnreleasedChangesDir(), constants.ENTRY_TYPES_FILE)
	local contents = renderEntryTypes(readCategories(), readKindNames())
	return {
		file = file,
		contents = contents,
		isCurrent = fs.exists(file) and fs.readFileToString(file) == contents,
	}
end

return planEntryTypes
