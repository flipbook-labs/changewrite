local function renderPullRequestLink(pr: number, repositoryUrl: string?): string
	if repositoryUrl then
		return `[#{pr}]({repositoryUrl}/pull/{pr})`
	end
	return `#{pr}`
end

return renderPullRequestLink
