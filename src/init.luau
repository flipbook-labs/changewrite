local entryRulesPath = require("@self/entries/rulesPath")

local Changewrite = {
	-- The folder of lint rules for changelog entries, to pass to `lute lint --rules`.
	ENTRY_RULES_PATH = entryRulesPath,
}

return table.freeze(Changewrite)
