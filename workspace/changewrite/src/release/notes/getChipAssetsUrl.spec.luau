local test = require("@std/test")

local getChipAssetsUrl = require("@root/release/notes/getChipAssetsUrl")

test.suite("getChipAssetsUrl", function(suite)
	suite:case("loads from raw.githubusercontent.com for a github.com repository", function(assert)
		assert.eq(
			getChipAssetsUrl("https://github.com/acme/widget", "main", "./.changes/assets"),
			"https://raw.githubusercontent.com/acme/widget/main/.changes/assets"
		)
	end)

	suite:case("uses the raw route on another GitHub server", function(assert)
		assert.eq(
			getChipAssetsUrl("https://git.example.com/acme/widget", "trunk", ".changes/assets/"),
			"https://git.example.com/acme/widget/raw/trunk/.changes/assets"
		)
	end)

	suite:case("percent-encodes the branch and directory", function(assert)
		assert.eq(
			getChipAssetsUrl("https://github.com/acme/widget", "release/v#2", "release notes/assets"),
			"https://raw.githubusercontent.com/acme/widget/release/v%232/release%20notes/assets"
		)
	end)

	suite:case("stays relative when the repository is unknown", function(assert)
		assert.eq(getChipAssetsUrl(nil, "main", "./.changes/assets"), ".changes/assets")
	end)
end)
