local process = require("@std/process")

local chomp = require("@root/chomp")
local config = require("@root/config")
local versionSource = require("@root/release/versionSource")

local function getLastVersionBumpCommit(version: string): string?
	local sourceFile = versionSource.getSourceFile()
	local result = process.run({
		config.gitCmd,
		"log",
		"-1",
		"--format=%H",
		"-S",
		version,
		"--",
		sourceFile,
	})
	assert(result.ok, result.stderr)

	local sha = chomp(result.stdout)
	if sha == "" then
		return nil
	end
	return sha
end

return getLastVersionBumpCommit
