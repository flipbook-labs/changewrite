local types = require("@root/release/types")

-- The markup for each of a repo's chips, keyed `kind/<name>` or `flag/<name>`.
export type ChipMarkup = { [string]: string }

-- What every part of the notes renders against.
export type NotesContext = {
	repositoryUrl: string?,
	chips: ChipMarkup,
	-- The entry files a changelog preview is about, keyed by path. When set,
	-- each part renders only the excerpt around these entries, and nil when it
	-- has none of them.
	focus: types.Focus?,
}

return nil
