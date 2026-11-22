local convertMarkdownEntryFiles = require("@root/fixes/convertMarkdownEntryFiles")
local convertTomlConfigFile = require("@root/fixes/convertTomlConfigFile")

-- The repairs `changewrite check --fix` makes before checking, such as moving
-- files written for an older version of Changewrite to their current format.
-- Every fix runs on every `--fix`, so each one does nothing when there's
-- nothing for it to repair.
--
-- They run in this order. The config comes first, because Changewrite can't
-- read its settings while changewrite.toml is there, and the next fix needs
-- them to find the changelog entries.
local FIXES: { () -> () } = {
	convertTomlConfigFile,
	convertMarkdownEntryFiles,
}

local function runFixes()
	for _, fix in FIXES do
		fix()
	end
end

return runFixes
