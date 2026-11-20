-- Each entry is one line in a long list. Its description holds detail only
-- some readers want, so it starts collapsed and the list stays scannable.
-- GitHub doesn't render Markdown inside `<summary>`, so the toggle has a plain
-- label and the entry's summary stays outside it.
local function renderCollapsedDescription(description: string): string
	return table.concat({
		"<details>",
		"<summary>Details</summary>",
		"",
		description,
		"",
		"</details>",
	}, "\n")
end

return renderCollapsedDescription
