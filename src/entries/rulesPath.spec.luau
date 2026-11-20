local fs = require("@std/fs")
local path = require("@std/path")
local test = require("@std/test")

local rulesPath = require("./rulesPath")

test.suite("rulesPath", function(suite)
	suite:case("is the absolute path of the entry rules folder", function(assert)
		assert.eq(path.isAbsolute(rulesPath), true)
		assert.eq(fs.exists(path.join(rulesPath, "summaryLength.luau")), true)
	end)
end)
