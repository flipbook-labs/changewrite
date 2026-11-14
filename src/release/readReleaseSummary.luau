local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local getUnreleasedChangesDir = require("@root/release/getUnreleasedChangesDir")
local parseReleaseSummary = require("@root/release/parseReleaseSummary")
local types = require("@root/release/types")

type ReleaseSummary = types.ReleaseSummary

local function readReleaseSummary(): ReleaseSummary?
	local file = path.join(getUnreleasedChangesDir(), constants.RELEASE_SUMMARY_FILE)
	if not fs.exists(file) then
		return nil
	end

	local success, parsed = pcall(parseReleaseSummary, fs.readFileToString(file))
	assert(success, `{file}: {parsed}`)
	return {
		file = file,
		name = parsed.name,
		tldr = parsed.tldr,
	}
end

return readReleaseSummary
