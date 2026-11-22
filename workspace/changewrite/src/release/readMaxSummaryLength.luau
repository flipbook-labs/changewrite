local parseMaxSummaryLength = require("@root/release/parseMaxSummaryLength")
local readConfig = require("@root/release/readConfig")

local function readMaxSummaryLength(): number
	return parseMaxSummaryLength(readConfig())
end

return readMaxSummaryLength
