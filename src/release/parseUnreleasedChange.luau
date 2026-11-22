local chomp = require("@root/chomp")
local constants = require("@root/release/constants")
local findRepeatedKey = require("@root/entries/findRepeatedKey")
local parseVersionComponent = require("@root/semver/parseVersionComponent")
local runEntry = require("@root/entries/runEntry")
local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag
type ParsedUnreleasedChange = types.ParsedUnreleasedChange

local DEFAULT_CATEGORY = "Changes"

local FIELDS = {
	"bump",
	"category",
	"kind",
	"flags",
	"highlight",
	"pr",
	"summary",
	"description",
}

local function readString(fields: { [string]: unknown }, name: string): string?
	local value = fields[name]
	assert(value == nil or typeof(value) == "string", `Unreleased change {name} must be a string`)
	return value :: string?
end

local function readFlags(value: unknown): { ChangeFlag }
	if value == nil then
		return {}
	end
	assert(typeof(value) == "table", `Unreleased change flags must be a list, such as \{ "breaking" \}`)

	local flags: { ChangeFlag } = {}
	for _, flag in value :: { unknown } do
		assert(typeof(flag) == "string", "Unreleased change flags must be a list of strings")
		assert(
			table.find(constants.CHANGE_FLAGS, flag) ~= nil,
			`Unreleased change flag "{flag}" is not supported. Expected any of: {table.concat(
				constants.CHANGE_FLAGS,
				", "
			)}`
		)
		if table.find(flags, flag :: ChangeFlag) == nil then
			table.insert(flags, flag :: ChangeFlag)
		end
	end
	return flags
end

local function readPullRequest(value: unknown): number?
	assert(
		value == nil or (typeof(value) == "number" and value >= 1 and value % 1 == 0),
		"Unreleased change pr must be a pull request number"
	)
	return value :: number?
end

-- An entry is a Luau file that returns a table of its fields. `runEntry` runs
-- it with a limited set of globals, so a value can be computed, such as a
-- description joined from paragraphs.
--
-- `categories` and `kinds` are the lists `changewrite.toml` configures. Once a
-- repo configures either list, every entry has to pick a value from it, so no
-- entry renders without a heading or a chip. Without a `categories` list, an
-- entry may leave out its category and lands under Changes. A repo that
-- configures no kinds can't use the field.
local function parseUnreleasedChange(
	source: string,
	categories: { string }?,
	kinds: { string }?
): ParsedUnreleasedChange
	local entry = runEntry(source)
	assert(typeof(entry) == "table", "Unreleased change must return a table of its fields")

	local repeated = findRepeatedKey(source)
	if repeated then
		error(
			`Unreleased change sets "{repeated.name}" more than once (line {repeated.line}). Luau keeps only the last value, so remove one`,
			0
		)
	end

	for name in entry :: { [unknown]: unknown } do
		assert(typeof(name) == "string", "Unreleased change fields must be written as `name = value`")
		assert(
			table.find(FIELDS, name) ~= nil,
			`Unreleased change has an unknown field "{name}". Expected any of: {table.concat(FIELDS, ", ")}`
		)
	end
	local fields = entry :: { [string]: unknown }

	local summary = chomp(readString(fields, "summary") or "")
	assert(summary ~= "", "Unreleased change has no summary")

	local bump = parseVersionComponent(readString(fields, "bump"))
	local category = readString(fields, "category")
	if categories then
		assert(category, `Unreleased change has no category. Expected one of: {table.concat(categories, ", ")}`)
		assert(
			table.find(categories, category) ~= nil,
			`Unreleased change category "{category}" is not configured. Expected one of: {table.concat(categories, ", ")}`
		)
	end

	local kind = readString(fields, "kind")
	local configuredKinds = kinds or {}
	if kind == nil then
		assert(
			#configuredKinds == 0,
			`Unreleased change has no kind. Expected one of: {table.concat(configuredKinds, ", ")}`
		)
	else
		assert(
			table.find(configuredKinds, kind) ~= nil,
			if #configuredKinds == 0
				then `Unreleased change kind "{kind}" is not configured. Add a [kind.{kind}] table to changewrite.toml`
				else `Unreleased change kind "{kind}" is not configured. Expected one of: {table.concat(
					configuredKinds,
					", "
				)}`
		)
	end

	local highlight = readString(fields, "highlight")
	if highlight == "" then
		highlight = nil
	end

	local description = chomp(readString(fields, "description") or "")

	return {
		bump = bump,
		category = category or DEFAULT_CATEGORY,
		summary = summary,
		body = if description == "" then nil else description,
		kind = kind,
		flags = readFlags(fields.flags),
		highlight = highlight,
		pr = readPullRequest(fields.pr),
	}
end

return parseUnreleasedChange
