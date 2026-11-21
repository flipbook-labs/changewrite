local luau = require("@std/luau")

-- Changelog entries and changewrite.luau both arrive in pull requests, and
-- `changewrite check` runs them on CI, sometimes for a fork. So these files can
-- use only these globals, which compute values and nothing else. Leaving out
-- `require`, `os`, `io`, and `process` keeps a file from reading other files,
-- reading secrets from the environment, or running commands. Lute's library
-- tables are read-only, so a file can't change them for the code that runs
-- after it either.
local ALLOWED_GLOBALS: { [string]: unknown } = {
	assert = assert,
	error = error,
	math = math,
	select = select,
	string = string,
	table = table,
	tonumber = tonumber,
	tostring = tostring,
	type = type,
	typeof = typeof,
	utf8 = utf8,
}
table.freeze(ALLOWED_GLOBALS)

local allowedNames: { string } = {}
for name in ALLOWED_GLOBALS do
	table.insert(allowedNames, name)
end
table.sort(allowedNames)

-- Runs a file's Luau source with only the allowed globals and returns the
-- value it returns. `name` says what the file is in errors, such as
-- "Unreleased change". Each run gets its own copy of the allowed globals, so a
-- global one file sets doesn't reach the next.
local function runSandboxed(source: string, name: string): unknown
	local loaded, chunk = pcall(function()
		return luau.load(luau.compile(source), name, table.clone(ALLOWED_GLOBALS) :: { [any]: any })
	end)
	assert(loaded, `{name} is not valid Luau: {chunk}`)

	local ran, value = pcall(chunk)
	assert(ran, `{name} failed to run: {value}. It can use only these globals: {table.concat(allowedNames, ", ")}`)
	return value
end

return runSandboxed
