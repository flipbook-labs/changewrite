local test = require("@std/test")

local renderEntryTypes = require("@root/entries/renderEntryTypes")

test.suite("renderEntryTypes", function(suite)
	suite:case("requires a category and kind from the configured lists", function(assert)
		local source = renderEntryTypes({ "Features", "Fixes" }, { "cli", "docs" })

		assert.strContains(source, 'export type Category = "Features" | "Fixes"\n')
		assert.strContains(source, 'export type Kind = "cli" | "docs"\n')
		assert.strContains(source, "\tcategory: Category,\n")
		assert.strContains(source, "\tkind: Kind,\n")
	end)

	suite:case("makes the category an optional string when no categories are configured", function(assert)
		local source = renderEntryTypes(nil, {})

		assert.strContains(source, "\tcategory: string?,\n")
		assert.strNotContains(source, "export type Category")
	end)

	suite:case("leaves out kind when no kinds are configured", function(assert)
		local source = renderEntryTypes({ "Fixes" }, {})

		assert.strNotContains(source, "Kind")
		assert.strNotContains(source, "kind:")
	end)

	suite:case("escapes quotes in configured names", function(assert)
		local source = renderEntryTypes({ 'The "Big" One' }, {})

		assert.strContains(source, 'export type Category = "The \\"Big\\" One"\n')
	end)

	suite:case("lists the supported flags and the free-text fields", function(assert)
		local source = renderEntryTypes(nil, {})

		assert.strContains(source, 'export type Flag = "breaking" | "deprecated" | "security"\n')
		assert.strContains(source, "\tflags: { Flag }?,\n")
		assert.strContains(source, "\tsummary: string,\n")
		assert.strContains(source, "\tdescription: string?,\n")
	end)
end)
