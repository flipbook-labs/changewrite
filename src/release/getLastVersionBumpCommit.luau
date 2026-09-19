local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")
local getSourceFile = require("@root/release/getSourceFile")

local function getLastVersionBumpCommit(version: string): string?
	local sourceFile = getSourceFile()
	local result = process.run({
		config.gitCmd,
		"log",
		"-1",
		"--format=%H",
		"-S",
		version,
		"--",
		tostring(sourceFile),
	})
	assert(result.ok, result.stderr)

	local sha = chomp(result.stdout)
	if sha == "" then
		return nil
	end
	return sha
end

return getLastVersionBumpCommit
