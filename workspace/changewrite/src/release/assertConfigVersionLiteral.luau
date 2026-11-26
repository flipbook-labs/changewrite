local constants = require("@root/release/constants")

--[[
	A version bump rewrites the first `current = "x.y.z"` in changewrite.luau,
	since the file has to be edited as text to keep the rest of it intact. That
	only lands on the right value when `version.current` is written as a string
	and nothing else in the file assigns a `current`. This checks both against
	`current`, the version the config returned when it ran, before anything is
	written.
]]
local function assertConfigVersionLiteral(content: string, current: string?): ()
	local pattern = constants.DEFAULT_PATTERNS[constants.CONFIG_FILE]
	local matches: { string } = {}
	for value in content:gmatch(pattern) do
		table.insert(matches, value)
	end

	assert(
		#matches > 0,
		`Write \`version.current\` as a string, such as current = "1.2.3", so Changewrite can update it in {constants.CONFIG_FILE}`
	)
	assert(
		#matches == 1,
		`{constants.CONFIG_FILE} assigns \`current\` more than once, so a version bump can't tell which one to update. Rename the other ones`
	)
	assert(
		matches[1] == current,
		`The \`current\` in {constants.CONFIG_FILE} holds "{matches[1]}", which doesn't match \`version.current\`. Write \`version.current\` as a string`
	)
end

return assertConfigVersionLiteral
