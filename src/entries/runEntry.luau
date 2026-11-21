local luau = require("@std/luau")

-- Entries arrive in pull requests, and `changewrite check` runs them on CI,
-- sometimes for a fork. So an entry can use only these globals, which compute
-- values and nothing else. Leaving out `require`, `os`, `io`, and `process`
-- keeps an entry from reading files, reading secrets from the environment, or
-- running commands. Lute's library tables are read-only, so an entry can't
-- change them for the code that runs after it either.
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

-- Runs an entry's source and returns the value it returns. Each run gets its
-- own copy of the allowed globals, so a global one entry sets doesn't reach the
-- next.
local function runEntry(source: string): unknown
	local loaded, chunk = pcall(function()
		return luau.load(luau.compile(source), "entry", table.clone(ALLOWED_GLOBALS) :: { [any]: any })
	end)
	assert(loaded, `Unreleased change is not valid Luau: {chunk}`)

	local ran, value = pcall(chunk)
	assert(
		ran,
		`Unreleased change failed to run: {value}. Entries can use only these globals: {table.concat(allowedNames, ", ")}`
	)
	return value
end

return runEntry
