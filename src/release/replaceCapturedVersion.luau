local function replaceCapturedVersion(content: string, pattern: string, nextVersion: string, file: string): string
	local startIndex, endIndex, currentVersion = content:find(pattern)
	assert(startIndex and endIndex and currentVersion, `Could not find a version in {file}`)

	local matched = content:sub(startIndex, endIndex)
	local relativeStart, relativeEnd = matched:find(currentVersion, 1, true)
	assert(relativeStart and relativeEnd, `Could not locate captured version in {file}`)

	return table.concat({
		content:sub(1, startIndex + relativeStart - 2),
		nextVersion,
		content:sub(startIndex + relativeEnd),
	})
end

return replaceCapturedVersion
