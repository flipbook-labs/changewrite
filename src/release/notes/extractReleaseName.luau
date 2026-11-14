local function extractReleaseName(notes: string): string?
	return notes:match("<!%-%- release%-name: (.-) %-%->")
end

return extractReleaseName
