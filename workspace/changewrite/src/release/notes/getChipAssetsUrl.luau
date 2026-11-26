-- The branch and directory come from the repo, so each part of their paths is
-- percent-encoded. A space would otherwise split a `srcset` entry, and a `#`
-- would turn the rest of the URL into a fragment.
local function encodePath(value: string): string
	local parts: { string } = {}
	for _, part in value:split("/") do
		local encoded = part:gsub("[^%w%-%._~]", function(character)
			return string.format("%%%02X", character:byte())
		end)
		table.insert(parts, encoded)
	end
	return table.concat(parts, "/")
end

--[[
	Where the notes load a repo's chips from. A release body needs absolute URLs,
	so chips load from the base branch, which is where `generate` output lands
	once its pull request merges. github.com serves raw files from its own host,
	and other GitHub servers serve them under the repository's `raw/` route.
	Without a known repository, the path stays relative to the repo root, where
	Changewrite writes CHANGELOG.md, so the images still show there on GitHub.
]]
local function getChipAssetsUrl(repositoryUrl: string?, baseBranch: string, assetsDir: string): string
	local trimmed = assetsDir:gsub("^%./", ""):gsub("/$", "")
	local dir = encodePath(trimmed)
	if repositoryUrl == nil then
		return dir
	end
	baseBranch = encodePath(baseBranch)
	local slug = repositoryUrl:match("^https://github%.com/(.+)$")
	if slug then
		return `https://raw.githubusercontent.com/{slug}/{baseBranch}/{dir}`
	end
	return `{repositoryUrl}/raw/{baseBranch}/{dir}`
end

return getChipAssetsUrl
