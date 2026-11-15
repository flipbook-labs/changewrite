-- Where the notes load a repo's chips from. A release body needs absolute URLs,
-- so chips load from the base branch, which is where `generate` output lands
-- once its pull request merges. github.com serves raw files from its own host,
-- and other GitHub servers serve them under the repository's `raw/` route.
-- Without a known repository, the path stays relative to the repo root, where
-- Changewrite writes CHANGELOG.md, so the images still show there on GitHub.
local function getChipAssetsUrl(repositoryUrl: string?, baseBranch: string, assetsDir: string): string
	local dir = assetsDir:gsub("^%./", ""):gsub("/$", "")
	if repositoryUrl == nil then
		return dir
	end
	local slug = repositoryUrl:match("^https://github%.com/(.+)$")
	if slug then
		return `https://raw.githubusercontent.com/{slug}/{baseBranch}/{dir}`
	end
	return `{repositoryUrl}/raw/{baseBranch}/{dir}`
end

return getChipAssetsUrl
