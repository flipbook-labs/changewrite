-- The markup for each of a repo's chips, keyed `kind/<name>` or `flag/<name>`.
export type ChipMarkup = { [string]: string }

-- What every part of the notes renders against.
export type NotesContext = {
	repositoryUrl: string?,
	chips: ChipMarkup,
}

return nil
