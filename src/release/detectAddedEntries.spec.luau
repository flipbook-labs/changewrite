local test = require("@std/test")

local detectAddedEntries = require("@root/release/detectAddedEntries")

local DIR = "./.changes/"

test.suite("detectAddedEntries", function(suite)
	suite:case("finds a new entry added on the branch", function(assert)
		local entries = detectAddedEntries({ ".changes/fix-thing.luau" }, DIR)

		assert.eq(#entries, 1)
		assert.eq(entries[1], ".changes/fix-thing.luau")
	end)

	suite:case("returns nothing when no files were added", function(assert)
		local entries = detectAddedEntries({}, DIR)

		assert.eq(#entries, 0)
	end)

	suite:case("ignores empty paths from a trailing newline in the diff", function(assert)
		local entries = detectAddedEntries({ ".changes/fix-thing.luau", "" }, DIR)

		assert.eq(#entries, 1)
		assert.eq(entries[1], ".changes/fix-thing.luau")
	end)

	suite:case("ignores changes that were not added under the directory", function(assert)
		local entries = detectAddedEntries({ "src/main.luau", "README.md" }, DIR)

		assert.eq(#entries, 0)
	end)

	suite:case("ignores the release summary in any letter case", function(assert)
		local entries = detectAddedEntries({ ".changes/release.md", ".changes/Release.md" }, DIR)

		assert.eq(#entries, 0)
	end)

	suite:case("ignores the directory's README", function(assert)
		local entries = detectAddedEntries({ ".changes/README.md" }, DIR)

		assert.eq(#entries, 0)
	end)

	suite:case("ignores files inside the directory that aren't Luau entries", function(assert)
		local entries = detectAddedEntries({ ".changes/notes.txt", ".changes/.gitkeep", ".changes/fix-thing.md" }, DIR)

		assert.eq(#entries, 0)
	end)

	suite:case("keeps only the entries added under the directory", function(assert)
		local entries = detectAddedEntries({
			"src/main.luau",
			".changes/README.md",
			".changes/add-feature.luau",
			".changes/fix-bug.luau",
		}, DIR)

		assert.eq(#entries, 2)
		assert.eq(entries[1], ".changes/add-feature.luau")
		assert.eq(entries[2], ".changes/fix-bug.luau")
	end)

	suite:case("drops duplicate paths from unioned git listings", function(assert)
		local entries = detectAddedEntries({
			".changes/add-feature.luau",
			".changes/add-feature.luau",
		}, DIR)

		assert.eq(#entries, 1)
		assert.eq(entries[1], ".changes/add-feature.luau")
	end)

	suite:case("ignores entries nested below the directory's top level", function(assert)
		-- `readUnreleasedChanges` lists the directory non-recursively, so a nested
		-- entry would pass `check` but be dropped at release time.
		local entries = detectAddedEntries({ ".changes/subdir/fix.luau" }, DIR)

		assert.eq(#entries, 0)
	end)

	suite:case("normalizes ./ prefixes on both the file and the directory", function(assert)
		local entries = detectAddedEntries({ "./.changes/fix-thing.luau" }, "./.changes/")

		assert.eq(#entries, 1)
		assert.eq(entries[1], "./.changes/fix-thing.luau")
	end)

	suite:case("honors a custom unreleased-changes directory", function(assert)
		local entries = detectAddedEntries({
			".changes/ignored.luau",
			"changelog.d/counts.luau",
		}, "changelog.d/")

		assert.eq(#entries, 1)
		assert.eq(entries[1], "changelog.d/counts.luau")
	end)
end)
