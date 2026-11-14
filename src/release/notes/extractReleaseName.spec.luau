local test = require("@std/test")

local extractReleaseName = require("@root/release/notes/extractReleaseName")

test.suite("extractReleaseName", function(suite)
	suite:case("reads the name from the notes' release-name comment", function(assert)
		local notes = "<!-- release-name: Out in the open -->\n\nFlipbook now runs outside Studio."

		assert.eq(extractReleaseName(notes), "Out in the open")
	end)

	suite:case("returns nil when the notes have no name", function(assert)
		assert.eq(extractReleaseName("### Fixes\n\n- Fix a thing."), nil)
	end)
end)
