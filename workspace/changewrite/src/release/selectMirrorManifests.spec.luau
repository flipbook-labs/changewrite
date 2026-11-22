local test = require("@std/test")

local selectMirrorManifests = require("@root/release/selectMirrorManifests")

test.suite("selectMirrorManifests", function(suite)
	suite:case("mirrors pkg.luau", function(assert)
		assert.eq(selectMirrorManifests({ "pkg.luau" }), { "pkg.luau" })
	end)

	suite:case("mirrors loom.config.luau when there is no pkg.luau", function(assert)
		assert.eq(selectMirrorManifests({ "loom.config.luau" }), { "loom.config.luau" })
	end)

	suite:case("mirrors pkg.luau in place of loom.config.luau when both exist", function(assert)
		assert.eq(selectMirrorManifests({ "loom.config.luau", "wally.toml", "pkg.luau" }), { "pkg.luau", "wally.toml" })
	end)

	suite:case("orders manifests by MIRROR_MANIFESTS regardless of input order", function(assert)
		assert.eq(
			selectMirrorManifests({ "package.json", "Cargo.toml", "wally.toml" }),
			{ "wally.toml", "Cargo.toml", "package.json" }
		)
	end)

	suite:case("ignores files that are not known manifests", function(assert)
		assert.eq(selectMirrorManifests({ "README.md" }), {})
	end)
end)
